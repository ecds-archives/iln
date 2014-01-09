<?xml version="1.0" encoding="ISO-8859-1"?>  
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:html="http://www.w3.org/TR/REC-html40" 
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:xql="http://metalab.unc.edu/xql/">

<!-- <xsl:include href="ilnshared.xsl"/>
<xsl:include href="teihtml-tables.xsl"/> -->

 <xsl:output method="xml"/>  

<xsl:template match="/">
   <xsl:apply-templates/> 
</xsl:template>


<xsl:template match="tei:interpGrp">
    <xsl:choose>
      <xsl:when test="count(tei:interp) > 1">
    <xsl:element name="h4">
	<xsl:value-of select="@type"/>
    </xsl:element>
    <xsl:element name="ul">
      <xsl:call-template name="interp"/>
    </xsl:element>
      </xsl:when>
      <xsl:when test="count(tei:interp) = 1">
	<xsl:element name="a">
	  <xsl:attribute name="href">illus-list.php?id=<xsl:value-of
	  select="tei:interp/@xml:id"/></xsl:attribute>
    <xsl:element name="h4">
	<xsl:value-of select="@type"/>
    </xsl:element>
	</xsl:element>
      </xsl:when>
    </xsl:choose>
</xsl:template>

<xsl:template name="interp">
<xsl:for-each select="tei:interp">
  <xsl:element name="li">
	<xsl:element name="a">
	  <xsl:attribute name="href">illus-list.php?id=<xsl:value-of
	  select="@xml:id"/></xsl:attribute>
	  <xsl:value-of select="."/></xsl:element>
  </xsl:element>
</xsl:for-each>
</xsl:template>

</xsl:stylesheet>
