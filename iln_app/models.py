import re
import datetime

from django.utils.safestring import mark_safe

from eulexistdb.manager import Manager
from eulexistdb.models import XmlModel
from eulxml.xmlmap.core import XmlObject 
from eulxml.xmlmap.dc import DublinCore
from eulxml.xmlmap.fields import StringField, NodeField, StringListField, NodeListField, Field
from eulxml.xmlmap.teimap import Tei, TeiDiv, _TeiBase, TEI_NAMESPACE, xmlmap, TeiInterpGroup, TeiInterp


class Fields(XmlModel, Tei):
    ROOT_NAMESPACES = {
        'tei' : TEI_NAMESPACE,
        'xml' : 'http://www.w3.org/XML/1998/namespace'}
    id = StringField('@xml:id')
    head = StringField('tei:head')
    img_head = StringField('//tei:figure/tei:head')
    vol = StringField('tei:bibl/tei:biblScope[@type="volume"]')
    issue = StringField('tei:bibl/tei:biblScope[@type="issue"]')
    pages = StringField('tei:bibl/tei:biblScope[@type="pages"]')
    date = StringField('tei:bibl/tei:date')
    type = StringField("@type")
    extent = StringField('tei:bibl/tei:extent')
    
class Volume_List(XmlModel, Tei):
    ROOT_NAMESPACES = {'tei' : TEI_NAMESPACE}
    objects = Manager('/tei:TEI')
    divs = NodeListField('//tei:div2', Fields)
    figs = NodeListField('//tei:figure', Fields)
    div_heads = NodeListField('//tei:div2/tei:head', 'self')
    id = StringField('//tei:div1/@xml:id')
    head = StringField('//tei:div1/tei:head')
    docDate = StringField('//tei:div1/tei:docDate')

class Volume(XmlModel, Tei):
    ROOT_NAMESPACES = {
        'tei' : TEI_NAMESPACE,}
    objects = Manager('//tei:div1')
    divs = NodeListField('//tei:div2', Fields)
    head = StringField('tei:head')
    id = StringField('@xml:id')
    

class Article(XmlModel, TeiDiv):
    ROOT_NAMESPACES = {'tei' : TEI_NAMESPACE}
    objects = Manager("//tei:div2")
    article = NodeField("//tei:div2", "self")
    id = StringField('@xml:id')
    head = StringField('tei:head')
    title = StringField('tei:bibl/tei:title')
    vol = StringField('tei:bibl/tei:biblScope[@type="volume"]')
    issue = StringField('tei:bibl/tei:biblScope[@type="issue"]')
    pages = StringField('tei:bibl/tei:biblScope[@type="pages"]')
    date = StringField('tei:bibl/tei:date')
    identifier_ark = StringField('tei:bibl/tei:idno')

    author = StringField("tei:byline//tei:sic")
    type = StringField("@type")

    #header = NodeField('ancestor::tei:TEI/tei:teiHeader', Volume_List)
    contributor = NodeField('ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt', Volume_List)
    publisher = NodeField('ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:publisher', Volume_List)
    rights = NodeField('ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/tei:p', Volume_List)
    issued_date = NodeField('ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date', Volume_List)
    site_url = 'http://beck.library.emory.edu/iln'
    series = NodeField('ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:title', Volume_List)

    # These variables duplicate the paths above.  Can another model help reduce code?
    volume = NodeField('ancestor::tei:div1', Volume)
    volume_id = NodeField('ancestor::tei:div1/@xml:id', Volume)
    volume_title = NodeField('ancestor::tei:div1/tei:head', Volume)
    nextdiv = NodeField("following::tei:div2[1]", "self")
    prevdiv = NodeField("preceding::tei:div2[1]", "self")
    nextdiv_id = NodeField("following::tei:div2[1]/@xml:id","self")
    prevdiv_id = NodeField("preceding::tei:div2[1]/@xml:id", "self")
    nextdiv_title = NodeField("following::tei:div2[1]/tei:head","self")
    prevdiv_title = NodeField("preceding::tei:div2[1]/tei:head", "self")
    nextdiv_vol = NodeField("following::tei:bibl/tei:biblScope[@type='volume']","self")
    prevdiv_vol = NodeField("preceding::tei:bibl/tei:biblScope[@type='volume']", "self")
    nextdiv_issue = NodeField("following::tei:bibl/tei:biblScope[@type='issue']","self")
    prevdiv_issue = NodeField("preceding::tei:bibl/tei:biblScope[@type='issue']", "self")
    nextdiv_pages = NodeField("following::tei:bibl/tei:biblScope[@type='pages']","self")
    prevdiv_pages = NodeField("preceding::tei:bibl/tei:biblScope[@type='pages']", "self")
    nextdiv_extent = NodeField("following::tei:bibl/tei:extent","self")
    prevdiv_extent = NodeField("preceding::tei:bibl/tei:extent", "self")
    nextdiv_type = NodeField("following::tei:div2[1]/@type","self")
    prevdiv_type = NodeField("preceding::tei:div2[1]/@type", "self")
    ana = StringField("@ana", "self") 
   
class Figure(XmlModel, Tei):
    ROOT_NAMESPACES = {
        'tei' : TEI_NAMESPACE,}
    objects = Manager('//tei:figure')
    head = StringField('tei:head')
    url = StringField('tei:graphic/@url')
    ana = StringField('tei:graphic/@ana')
    width = StringField('tei:graphic/@width')
    height = StringField('tei:graphic/@height')
    vol = NodeField('ancestor::tei:div1/@xml:id', Volume)
    issue = NodeField('ancestor::tei:div2/tei:bibl/tei:biblScope[@type="issue"]', 'self')
    pages = NodeField('ancestor::tei:div2/tei:bibl/tei:biblScope[@type="pages"]', 'self')
    date = NodeField('ancestor::tei:div2/tei:bibl/tei:date', 'self')
    vol_id = NodeField('ancestor::tei:div1/@xml:id', 'self')

class InterpGroup(XmlModel, Tei):
    ROOT_NAMESPACES = {'tei' : TEI_NAMESPACE}
    objects = Manager('//tei:interpGrp')
    items = NodeListField('tei:interp', Fields)
    name = StringField('@type', 'self')
