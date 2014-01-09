<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:html="http://www.w3.org/TR/REC-html40" 
	xmlns:xql="http://metalab.unc.edu/xql/"
	xmlns:exist="http://exist.sourceforge.net/NS/exist"
	exclude-result-prefixes="exist" version="1.0"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:js="javascript:code"
  	extension-element-prefixes="js">


<!-- <xsl:variable name="query"><xsl:value-of
select="ino:response/xql:query"/></xsl:variable> -->
<!-- <xsl:variable
name="base_url">http://tamino.library.emory.edu/passthru/servlet/transform/tamino/BECKCTR/ILN</xsl:variable>  -->
<xsl:variable name="image_url">http://beck.library.emory.edu/iln/image-content/</xsl:variable>

<!-- define variables for all xsl files -->
<xsl:variable name="xsl_contents">ilncontents.xsl</xsl:variable>
<xsl:variable name="xsl_imgview">imgview.xsl</xsl:variable>
<xsl:variable name="xslurl">&amp;_xslsrc=xsl:stylesheet/</xsl:variable>


<!-- display figure & link to image-viewer -->
<xsl:template match="tei:figure">
<xsl:variable name="fig_value" select="./tei:graphic/@url"/>
<xsl:variable name="fig_id">
  <xsl:choose>
    <xsl:when test="contains($fig_value, '.jpg')">
      <xsl:value-of select="substring-before($fig_value, '.jpg')"/>
      <!-- <xsl:text>DEBUG: url contains .jpg </xsl:text> -->
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="$fig_value"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
    <xsl:element name="table">
      <xsl:element name="tr">
        <xsl:element name="td">

<!-- javascript version of the image & link -->
      <xsl:element name="a">
	<xsl:attribute
name="href">javascript:launchViewer('figure.php?id=<xsl:value-of select="$fig_value"/>')</xsl:attribute>
<xsl:element name="img">
  <xsl:attribute name="class">javascript</xsl:attribute>
  <xsl:attribute name="src"><xsl:value-of select="concat($image_url, 'ILN', $fig_id, '.gif')"/></xsl:attribute>
  <xsl:attribute name="alt">view image</xsl:attribute>
  </xsl:element> <!-- end img -->
  </xsl:element> <!-- end a --> 

<!-- non javascript version of image & link -->
  <noscript>
      <xsl:element name="a">
	<xsl:attribute name="href">figure.php?id=<xsl:value-of select="$fig_value"/></xsl:attribute>
        <xsl:attribute name="target">ILN_image_viewer</xsl:attribute>
        <!-- open a new window without javascript -->
  <xsl:element name="img">
  <xsl:attribute name="src"><xsl:value-of select="concat($image_url, 'ILN', $fig_id, '.gif')"/></xsl:attribute>
  <xsl:attribute name="alt">view image</xsl:attribute>
  </xsl:element> <!-- end img -->
  </xsl:element> <!-- end a --> 
 </noscript> 

  </xsl:element> <!-- end td -->

   <xsl:element name="td">
     <xsl:element name="p">
      <xsl:attribute name="class">caption</xsl:attribute>
      <xsl:value-of select="tei:head"/>
     </xsl:element> <!-- p -->

  </xsl:element> <!-- end td -->
  </xsl:element> <!-- end tr --> 
  </xsl:element>  <!-- end table -->
</xsl:template>


<!-- print out div titles in table of contents style -->
 <xsl:template match="tei:div2"> 
 <xsl:element name="p">
  <xsl:element name="a">
    <xsl:attribute name="href">browse.php?id=<xsl:value-of select="@xml:id"/><xsl:if test="$term_string"><xsl:value-of select="$term_string"/></xsl:if></xsl:attribute>
  <xsl:if test="head = ''">[Untitled]</xsl:if>
  <xsl:apply-templates select="tei:head"/>
  </xsl:element> <!-- a -->

  <!-- put bibliographic info on second line -->
  <xsl:element name="br"/>
 <xsl:element name="font">
 <xsl:attribute name="size">-1</xsl:attribute>
  <xsl:value-of select="tei:bibl/tei:biblScope[@type='volume']" />,
  <xsl:value-of select="tei:bibl/tei:biblScope[@type='issue']" />,  
  <xsl:value-of select="tei:bibl/tei:biblScope[@type='pages']" />.  
  <xsl:value-of select="tei:bibl/tei:date" /> 
  - <xsl:value-of select="./@type"/>
  <xsl:if test="tei:bibl/tei:extent">
      - (<xsl:value-of select="tei:bibl/tei:extent" />)
  </xsl:if>
  </xsl:element> <!-- end font -->
 </xsl:element> <!-- end p -->

</xsl:template>

<!--
<xsl:template match="@*|node()" name="default"> 
  <xsl:value-of select="."/>
</xsl:template>
-->
</xsl:stylesheet>
