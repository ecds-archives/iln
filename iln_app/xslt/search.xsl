<?xml version="1.0" encoding="utf-8"?> 

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exist="http://exist.sourceforge.net/NS/exist"
	xmlns:html="http://www.w3.org/TR/REC-html40" version="1.0"
	xmlns:xql="http://metalab.unc.edu/xql/">

<!-- <xsl:include href="ilnshared.xsl"/> -->

  <!-- search terms -->
  <xsl:param name="keyword"/>
  <xsl:param name="doctitle"/>
  <xsl:param name="date"/>
  <xsl:param name="subject"/>

<!-- construct string to pass search term values to browse via url -->
<!-- <xsl:variable name="term_string"><xsl:if test="$term !=
0">&amp;term=<xsl:value-of select="$term"/></xsl:if><xsl:if
test="$term2 != 0">&amp;term2=<xsl:value-of
select="$term2"/></xsl:if><xsl:if test="$term3 !=
0">&amp;term3=<xsl:value-of select="$term3"/></xsl:if></xsl:variable> -->

  <xsl:variable name="term_string">keyword=<xsl:value-of select="$keyword"/>&amp;doctitle=<xsl:value-of select="$doctitle"/>&amp;date=<xsl:value-of select="$date"/>&amp;author=<xsl:value-of select="$auth"/>&amp;subject=<xsl:value-of select="$subject"/>&amp;</xsl:variable>

<xsl:output method="html"/>  

<xsl:template match="/">
DEBUG: in root template 
    <!-- returning at the div2 (article/illustration) level -->
    <xsl:apply-templates select="//div2"/>
</xsl:template> <!-- / -->


<xsl:template match="div2">
    <!-- pull out table of contents information -->
    <xsl:choose>
      <xsl:when test="//div2/hits"> 
        <xsl:element name="table">
          <xsl:attribute name="class">searchresults</xsl:attribute>
	  <xsl:element name="tr">
	    <xsl:element name="th"/>
	    <xsl:element name="th">number of matches</xsl:element>
	  </xsl:element>
          <xsl:apply-templates select="//div2" mode="count"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="//div2" />
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- put article title in a table in order to align matches count off to the side -->
<xsl:template match="div2" mode="count">
  <xsl:element name="tr">
    <xsl:element name="td">
      <xsl:apply-templates select="."/>
    </xsl:element>
    <xsl:element name="td">
      <xsl:attribute name="class">count</xsl:attribute>
	<!-- number of matches for a search -->
      <xsl:apply-templates select="hits"/>
    </xsl:element>
  </xsl:element>
</xsl:template>

<!-- print out div titles in table of contents style -->
 <xsl:template match="div2"> 
 <xsl:element name="p">
  <xsl:element name="a">
    <xsl:attribute name="href">browse.php?id=<xsl:value-of select="@id"/><xsl:if test="$term_string"><xsl:value-of select="$term_string"/></xsl:if></xsl:attribute>
  <xsl:if test="head = ''">[Untitled]</xsl:if>
  <xsl:apply-templates select="head"/>
  </xsl:element> <!-- a -->

  <!-- put bibliographic info on second line -->
  <xsl:element name="br"/>
 <xsl:element name="font">
 <xsl:attribute name="size">-1</xsl:attribute>
  <xsl:value-of select="bibl/biblScope[@type='volume']" />,
  <xsl:value-of select="bibl/biblScope[@type='issue']" />,  
  <xsl:value-of select="bibl/biblScope[@type='pages']" />.  
  <xsl:value-of select="bibl/date" /> 
  - <xsl:value-of select="./@type"/>
  <xsl:if test="bibl/extent">
      - (<xsl:value-of select="bibl/extent" />)
  </xsl:if>
  </xsl:element> <!-- end font -->
 </xsl:element> <!-- end p -->

</xsl:template>

</xsl:stylesheet>
