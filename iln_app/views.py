import os
import re
import collections
from urllib import urlencode
import logging
import tempfile, zipfile
from django.core.servers.basehttp import FileWrapper
import mimetypes

from django.conf import settings
from django.shortcuts import render, render_to_response
from django.http import HttpResponse, Http404
from django.core.paginator import Paginator, InvalidPage, EmptyPage
from django.template import RequestContext

from iln_app.models import Volume_List, Volume, Article, Fields, Figure, InterpGroup, Subject
from iln_app.forms import SearchForm

from eulxml.xmlmap.core import load_xmlobject_from_file
from eulxml.xmlmap.teimap import Tei, TeiDiv, _TeiBase, TEI_NAMESPACE, xmlmap
from eulcommon.djangoextras.http.decorators import content_negotiation
from eulexistdb.query import escape_string
from eulexistdb.exceptions import DoesNotExist, ReturnedMultiple

logger = logging.getLogger(__name__)

def index(request):
  return render_to_response('index.html', context_instance=RequestContext(request))
  
def introduction(request):
  return render_to_response('introduction.html', context_instance=RequestContext(request))

def bibliography(request):
  file = xmlmap.load_xmlobject_from_file(filename=os.path.join(settings.BASE_DIR, 'static', 'xml', 'bibl.xml'))
  body = file.xsl_transform(filename=os.path.join(settings.BASE_DIR, '..', 'iln_app', 'xslt', 'bibl.xsl'))
  return render_to_response('bibliography.html', {'body' : body.serializeDocument()}, context_instance=RequestContext(request))

def about(request):
  return render_to_response('about.html', context_instance=RequestContext(request))

def links(request):
  file = xmlmap.load_xmlobject_from_file(filename=os.path.join(settings.BASE_DIR, 'static', 'xml', 'links.xml'))
  body = file.xsl_transform(filename=os.path.join(settings.BASE_DIR, '..', 'iln_app', 'xslt', 'links.xsl'))
  return render_to_response('links.html', {'body' : body.serializeDocument()}, context_instance=RequestContext(request))

def searchform(request, scope=None):
    "Search by articles and illustrations by keyword/title/date"
    form = SearchForm(request.GET)
    response_code = None
    context = {'searchform': form}
    search_opts = {}
    number_of_results = 20
      
    if form.is_valid():
        if 'keyword' in form.cleaned_data and form.cleaned_data['keyword']:
            search_opts['fulltext_terms'] = '%s' % form.cleaned_data['keyword']
        if 'title' in form.cleaned_data and form.cleaned_data['title']:
            search_opts['head__fulltext_terms'] = '%s' % form.cleaned_data['title']
        if 'article_date' in form.cleaned_data and form.cleaned_data['article_date']:
            search_opts['date__contains'] = '%s' % form.cleaned_data['article_date']
        if 'illustration_date' in form.cleaned_data and form.cleaned_data['illustration_date']:
            search_opts['article__date__contains'] = '%s' % form.cleaned_data['illustration_date']

        if scope == 'text':
          items = Article.objects.only("id", "head", "vol", "issue", "pages", "date", "type", "extent", "volume_id").also('fulltext_score').filter(**search_opts).filter('-highlight').order_by('-fulltext_score')
        if scope == 'illustrations':
          items = Figure.objects.only("id", "head", "article__id", "article__vol", "article__issue", "article__pages", "article__date", "article__type", "article__extent", "url").filter(**search_opts).order_by('-fulltext_score')
        
        searchform_paginator = Paginator(items, number_of_results)
                
        try:
            page = int(request.GET.get('page', '1'))
        except ValueError:
            page = 1
        # If page request (9999) is out of range, deliver last page of results.
        try:
            searchform_page = searchform_paginator.page(page)
        except (EmptyPage, InvalidPage):
            searchform_page = searchform_paginator.page(paginator.num_pages)

        range_dict = {}
        for page in searchform_page.paginator.page_range:
          range_dict[page] = str(searchform_paginator.page(page).start_index()) + ' - ' + str(searchform_paginator.page(page).end_index())

        context['scope'] = scope
        context['items'] = items
        context['items_paginated'] = searchform_page
        context['range_lookup'] = range_dict
        context['items_count'] = searchform_page.paginator.count
        context['keyword'] = form.cleaned_data['keyword']
        context['title'] = form.cleaned_data['title']
        context['article_date'] = form.cleaned_data['article_date']
        context['illustration_date'] = form.cleaned_data['illustration_date']
        context['search_opts'] = search_opts
           
        response = render_to_response('search_results.html', context, context_instance=RequestContext(request))                
    else:
        response = render(request, 'search.html', {"searchform": form})       
    if response_code is not None:
        response.status_code = response_code
    return response

def article_display(request, div_id):
  "Display the contents of a single article."
  search_fields = ['keyword', 'title', 'article_date', 'illustration_date']
  if 'keyword' in request.GET:
    search_terms = request.GET['keyword']
    url_params = '?' + urlencode({'keyword': search_terms})
    filter = {'highlight': search_terms}    
  else:
    url_params = ''
    filter = {}
  try:
    return_fields = ['article', 'prevdiv_id', 'prevdiv_title', 'prevdiv_vol', 'prevdiv_issue', 'prevdiv_pages', 'prevdiv_extent', 'prevdiv_type', 'nextdiv_id', 'nextdiv_title', 'nextdiv_vol', 'nextdiv_issue', 'nextdiv_pages', 'nextdiv_extent', 'nextdiv_type', 'volume_id', 'volume_title', 'head', 'title', 'vol', 'issue', 'pages', 'date', 'identifier_ark', 'contributor', 'publisher', 'rights', 'issued_date', 'series']
    div = Article.objects.only(*return_fields).filter(**filter).get(id=div_id)
    body = div.article.xsl_transform(filename=os.path.join(settings.BASE_DIR, '..', 'iln_app', 'xslt', 'article.xsl'))
    id = div_id
    return render_to_response('article_display.html', {'div': div, 'body' : body.serialize(), 'id': id}, context_instance=RequestContext(request))
  except DoesNotExist:
        raise Http404

def volumes(request):
  volumes = Volume_List.objects.only('id', 'head', 'docDate', 'divs').order_by('id')  
  return render_to_response('volumes.html', {'volumes': volumes}, context_instance=RequestContext(request))

def volume_display(request, vol_id):
  "Display the contents of a single volume."
  volume = Volume.objects.get(id__exact=vol_id)
  body = volume.xsl_transform(filename=os.path.join(settings.BASE_DIR, '..', 'iln_app', 'xslt', 'volume.xsl'))
  return render_to_response('volume_display.html', {'volume': volume, 'body' : body.serialize()}, context_instance=RequestContext(request))

def volume_xml(request, vol_id):
  "Display the xml of a single volume."
  try:
    doc = Volume.objects.get(id__exact=vol_id)
  except:
    raise Http404
  tei_xml = doc.serializeDocument(pretty=True)
  return HttpResponse(tei_xml, mimetype='application/xml')

def illustrations(request):
  volumes = Volume_List.objects.only('id', 'head', 'docDate', 'figs').order_by('id')
  figures = Figure.objects.also('volume__id', 'article__id', 'article__title', 'article__vol', 'article__issue', 'article__pages', 'article__date').all()

  return render_to_response('illustrations.html', {'volumes':volumes, 'figures':figures}, context_instance=RequestContext(request))

def illustration_display(request, fig_url):
  try:
    figure = Figure.objects.get(url__exact=fig_url)
  except:
    raise Http404
  return render_to_response('illustration_display.html', {'figure': figure,}, context_instance=RequestContext(request))

def illustration_display_large(request, fig_url):
  try:
    figure = Figure.objects.get(url__exact=fig_url)
  except:
    raise Http404
  return render_to_response('illustration_display_large.html', {'figure': figure,}, context_instance=RequestContext(request))

def illustration_display_full(request, fig_url):
  try:
    figure = Figure.objects.get(url__exact=fig_url)
  except:
    raise Http404
  return render_to_response('illustration_display_full.html', {'figure': figure,}, context_instance=RequestContext(request))

def illus_subj(request):
  "View list of subjects for illustrations"
  groups = InterpGroup.objects.only('items', 'name')
  return render_to_response('subjects.html', {'groups' : groups}, context_instance=RequestContext(request))

def subject_display(request, subj_id):
  "View list of illustrations for a subject"
  subject = Subject.objects.filter(id__exact=subj_id).distinct()
  response_code = None
  context = {}
  number_of_results = 20

  figures = Figure.objects.only("id", "head", "article__id", "article__vol", "article__issue", "article__pages", "article__date", "article__type", "article__extent", "url").filter(ana__contains=subj_id)

  subject_paginator = Paginator(figures, number_of_results)
  try:
    page = int(request.GET.get('page', '1'))
  except ValueError:
    page = 1
  # If page request (9999) is out of range, deliver last page of results.
  try:
    subject_page = subject_paginator.page(page)
  except (EmptyPage, InvalidPage):
    subject_page = subject_paginator.page(paginator.num_pages)

  context['subject'] = subject
  context['items'] = figures
  context['items_paginated'] = subject_page
  context['items_count'] = subject_page.paginator.count

  return render_to_response('subject_display.html', context, context_instance=RequestContext(request))

def send_file(request, basename):
    if basename[3] == '_':
        extension = '.zip'
    else:
        extension = '.txt'
    filepath = 'static/txt/' + basename + extension
    filename  = os.path.join(settings.BASE_DIR, filepath )
    download_name = basename + extension
    wrapper      = FileWrapper(open(filename))
    content_type = mimetypes.guess_type(filename)[0]
    response     = HttpResponse(wrapper,content_type=content_type)
    response['Content-Length']      = os.path.getsize(filename)    
    response['Content-Disposition'] = "attachment; filename=%s"%download_name
    return response
