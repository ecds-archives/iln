<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dc="http://purl.org/dc/elements/1.1/" version="1.0">

  <xsl:output method="xml"/>

  <!-- brief listing of link records (in Dublin Core format) -->

  <xsl:template match="/">
    <div>
    <xsl:apply-templates select="//biblRecord">
      <xsl:sort select="dc:creator"/>
      <xsl:sort select="dc:title"/>
    </xsl:apply-templates>
    </div>
  </xsl:template>
    
  <xsl:template match="biblRecord">
     
    <xsl:element name="p">
        <xsl:apply-templates select="dc:creator"/><xsl:text>.
	</xsl:text><xsl:element name="i"><xsl:value-of select="dc:title"/></xsl:element><xsl:text>. </xsl:text>
	<xsl:value-of select="dc:publisher"/><xsl:text>, </xsl:text><xsl:value-of select="dc:date"/><xsl:text>.</xsl:text>
<xsl:apply-templates select="dc:identifier"/>
      <xsl:element name="br"/>
      
      <xsl:value-of select="dc:description"/>
    </xsl:element> <!-- p -->
  </xsl:template>  <!-- end record -->
  
  <xsl:template match="dc:creator">
    <xsl:choose>
      <xsl:when test="position() = 1"/>
      <xsl:when test="position() = last()">
        <xsl:text> and </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>, </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
      <xsl:apply-templates />
  </xsl:template>
  
  <xsl:template match="dc:identifier">
    <xsl:element name="br"/>
    <xsl:element name="font">
      <xsl:attribute name="size">-1</xsl:attribute>
      (<xsl:value-of select="."/>)
    </xsl:element> <!-- font -->
  </xsl:template>
  
  
</xsl:stylesheet>
