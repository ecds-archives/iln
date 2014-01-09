<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:dc="http://purl.org/dc/elements/1.1/"
		xmlns:dcterms="http://purl.org/dc/terms"
                version="1.0">

  <xsl:output method="xml" omit-xml-declaration="yes"/>
  <xsl:variable name="baseurl">http://beck.library.emory.edu/</xsl:variable>
  <xsl:variable name="siteurl">iln</xsl:variable>

  <xsl:param name="qualified">true</xsl:param>



  <xsl:template match="/">
    <dc>
      <xsl:call-template name="article-info"/>
      <xsl:call-template name="issue-info"/>
      <xsl:call-template name="common-fields"/>
    </dc>
  </xsl:template>


 	
  <!-- static fields for all records-->
  <xsl:template name="common-fields">
    <dc:language>English</dc:language>
    <dc:subject>
      <xsl:if test="$qualified='true'">
        <xsl:attribute name="scheme">LSCH</xsl:attribute>
      </xsl:if>
      <xsl:text>United States--History--Civil War, 1861-1865--Sources.</xsl:text>
    </dc:subject>
    <dc:subject>
      <xsl:if test="$qualified = 'true'">
        <xsl:attribute name="scheme">LSCH</xsl:attribute>
      </xsl:if>
      <xsl:text>United States--History--Civil War, 1861-1865--Foreign public opinion.</xsl:text>
    </dc:subject>
    <dc:subject>
      <xsl:if test="$qualified = 'true'">
        <xsl:attribute name="scheme">LSCH</xsl:attribute>
      </xsl:if>
      <xsl:text>United States--Politics and government--1861-1865.</xsl:text>
    </dc:subject>

    <dc:type>Text</dc:type>
    <dc:format>text/xml</dc:format>
  </xsl:template>
  

  <xsl:template name="article-info">
    <xsl:element name="dc:title">
      <xsl:apply-templates select=".//tei:div2/tei:head"/>
    </xsl:element>
    <xsl:element name="dc:source">
      <!-- process all elements, in this order. -->
      <xsl:apply-templates select=".//tei:div2/tei:bibl/tei:title"/>
      <xsl:apply-templates select=".//tei:div2/tei:bibl/tei:biblScope[@type='volume']"/>
      <xsl:apply-templates select=".//tei:div2/tei:bibl/tei:biblScope[@type='issue']"/>
      <xsl:apply-templates select=".//tei:div2/tei:bibl/tei:biblScope[@type='pages']"/>
      <xsl:apply-templates select=".//tei:div2/tei:bibl/tei:date"/>
    </xsl:element>
     <xsl:element name="dc:identifier">
      <xsl:apply-templates select=".//tei:div2/tei:bibl/tei:idno[@type='ark']"/>
    </xsl:element>
  </xsl:template>

  <!-- format bibl elements -->
  <xsl:template match="tei:bibl">
    <xsl:value-of select="tei:title"/><xsl:text>, </xsl:text>
    <xsl:value-of select="tei:biblScope[@type='volume']"/><xsl:text>, </xsl:text>
    <xsl:value-of select="tei:biblScope[@type='issue']"/><xsl:text>, </xsl:text>
    <xsl:value-of
      select="tei:biblScope[@type='pages']"/><xsl:text>, </xsl:text>
    <xsl:value-of select="tei:date"/><xsl:text>. </xsl:text>
  </xsl:template>

<xsl:template name="issue-info">
  <!-- <xsl:apply-templates select="TEI/teiHeader"/> -->
  <!-- specific to ILN : Sandra Still's name should show up -->
    <xsl:element name="dc:contributor">
      <xsl:apply-templates select=".//tei:titleStmt/tei:respStmt/tei:resp"/><xsl:text> </xsl:text><xsl:apply-templates select=".//tei:titleStmt/tei:respStmt/tei:name"/>
    </xsl:element>
  <!-- publisher -->
    <xsl:element name="dc:publisher">  <xsl:apply-templates select=".//tei:publicationStmt/tei:publisher"/>, <xsl:value-of select=".//tei:publicationStmt/tei:pubPlace"/>. <xsl:apply-templates select=".//tei:publicationStmt/tei:date"/>: <xsl:apply-templates select=".//tei:publicationStmt/tei:address/tei:addrLine"/>.</xsl:element> 
    <!-- pick up rights statement --> 
    <xsl:apply-templates select=".//tei:availability"/>

    <xsl:choose>
      <xsl:when test="$qualified = 'true'">
        <xsl:element name="dcterms:issued">
          <xsl:apply-templates select=".//tei:publicationStmt/tei:date"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="dc:date">
          <xsl:apply-templates select=".//tei:publicationStmt/tei:date"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  
  <xsl:choose>
    <xsl:when test="$qualified = 'true'">
      <xsl:element name="dcterms:isPartOf"><xsl:apply-templates select=".//tei:seriesStmt/tei:title"/></xsl:element>
      
      <xsl:element name="dcterms:isPartOf">
        <xsl:attribute name="scheme">URI</xsl:attribute>
        <xsl:text>http://beck.library.emory.edu/iln/</xsl:text>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <!-- FIXME: should both be included for unqualified dublin core? -->
      <xsl:element name="dc:relation"><xsl:value-of select=".//tei:seriesStmt/tei:title"/></xsl:element>
      <xsl:element name="dc:relation">http://beck.library.emory.edu/iln/</xsl:element>
    </xsl:otherwise>
  </xsl:choose>
  
  </xsl:template>

  <!-- ignore for now; do these fit anywhere? -->
  <xsl:template match="tei:publicationStmt/tei:address"/>
  <xsl:template match="tei:publicationStmt/tei:pubPlace|tei:imprint/tei:pubPlace|tei:pubPlace"/>
  <xsl:template match="tei:respStmt"/>

  <xsl:template match="tei:availability">
    <xsl:element name="dc:rights">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

<!--  <xsl:template match="seriesStmt/title">

 </xsl:template>-->
<!--
  <xsl:template match="sourceDesc/bibl">
    <xsl:element name="dc:source"> -->
      <!-- process all elements, in this order. -->
<!--      <xsl:apply-templates select="title"/>
      <xsl:apply-templates select="biblScope"/>
      <xsl:apply-templates select="date"/> -->
      <!-- in case source is in plain text, without tags -->
<!--      <xsl:apply-templates select="text()"/>
    </xsl:element>
  </xsl:template>
-->
  <!-- formatting for bibl elements, to generate a nice citation. -->
  <xsl:template match="tei:bibl/tei:author"><xsl:apply-templates/>. </xsl:template>
  <xsl:template match="tei:bibl/tei:title">
    <xsl:apply-templates/>
    <xsl:if test="not(contains(., '.'))"><xsl:text>.</xsl:text></xsl:if>	<!-- hack; add period? -->
    <xsl:text> </xsl:text>
  </xsl:template>  

   <xsl:template match="tei:bibl/tei:editor">
    <xsl:text>Ed. </xsl:text><xsl:apply-templates/><xsl:text>. </xsl:text> 
  </xsl:template> 
  <xsl:template match="tei:bibl/tei:pubPlace">
    <xsl:if test=". != ''">
      <xsl:apply-templates/>
      <xsl:text>: </xsl:text>
    </xsl:if>
  </xsl:template> 
  <xsl:template match="tei:bibl/tei:biblScope"> 
    <xsl:if test=". != ''"><xsl:apply-templates/>, </xsl:if>
  </xsl:template> 
  <xsl:template match="tei:bibl/tei:date"><xsl:apply-templates/>.</xsl:template>


  <!-- generic description, same on all records - don't include -->
  <xsl:template match="tei:encodingDesc/tei:projectDesc"/>

  <!-- ark identifier -->
<!--  <xsl:template match="idno[@type='ark']">
    <xsl:element name="dc:identifier">
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template> -->

  <!-- ignore other rs types for now -->
  <xsl:template match="profileDesc/creation/rs[@type!='geography']"/>

  <!-- ignore these: encoding specific information -->
  <xsl:template match="tei:encodingDesc/tei:tagsDecl"/>
  <xsl:template match="tei:encodingDesc/tei:refsDecl"/>
  <xsl:template match="tei:encodingDesc/tei:editorialDecl"/>
  <xsl:template match="tei:revisionDesc"/>

  <!-- ignore header title -->
  <xsl:template match="tei:titleStmt/tei:title"/>
  <!-- ignore div2 elements outside of template -->
  <!--<xsl:template match="div2/head"/>-->
  <xsl:template match="tei:div2/tei:bibl"/>

  <!-- do nothing with these -->
   <xsl:template match="tei:div2/tei:p"/>
    <xsl:template match="issueid"/>
     <xsl:template match="siblings"/>
  <!-- ignore bibls within the text for now -->
  <xsl:template match="tei:text//tei:bibl"/>

  <!-- normalize space for all text nodes -->
  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>


</xsl:stylesheet>
