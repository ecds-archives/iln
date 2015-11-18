from django.conf.urls import patterns, include, url
from django.conf import settings

from django.contrib import admin
admin.autodiscover()

from iln_app.views import index, introduction, bibliography, about, links, searchform, article_display, volumes, volume_display, illustrations, illustration_display, volume_xml, illus_subj, send_file

urlpatterns = patterns('iln_app.views',
    url(r'^$', 'index', name='index'),
    url(r'^introduction$', 'introduction', name='introduction'),
    url(r'^bibliography$', 'bibliography', name='bibliography'),
    url(r'^about$', 'about', name='about'),
    url(r'^links$', 'links', name='links'),
    url(r'^search$', 'searchform', name='searchform'),
    url(r'^search/(?P<scope>[^/]+)/$', 'searchform', name='search_results'),
    url(r'^browse/(?P<div_id>[^/]+)/$', 'article_display', name='article_display'),
    url(r'^volume/(?P<vol_id>[^/]+)/$', 'volume_display', name='volume_display'),
    url(r'^volume/(?P<vol_id>[^/]+)/xml$', 'volume_xml', name='volume_xml'),
    url(r'^volumes$', 'volumes', name='volumes'),
    url(r'^illustrations$', 'illustrations', name='illustrations'),
    url(r'^illustration/(?P<fig_url>[^/]+)/$', 'illustration_display', name='illustration_display'),
    url(r'^illus-subj$', 'illus_subj', name='illus_subj'),
    url(r'^illus-subj/(?P<subj_id>[^/]+)/$', 'subject_display', name='subject_display'),
    url(r'^(?P<basename>[^/]+)/download$', 'send_file', name='send_file'),
    url(r'^illustrationlarge/(?P<fig_url>[^/]+)/$', 'illustration_display_large', name='illustration_display_large'),
    url(r'^illustrationfull/(?P<fig_url>[^/]+)/$', 'illustration_display_full', name='illustration_display_full'),

    )
   
if settings.DEBUG:
  urlpatterns += patterns(
    url(r'^static/(?P<path>.*)$', 'django.views.static.serve', {'document_root': settings.STATIC_ROOT } ),
)

