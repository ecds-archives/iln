<?xml version="1.0" encoding="ISO-8859-1"?> 

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		version ="1.0">

<xsl:output method="xml"/>

<xsl:template match="/">
<xsl:apply-templates/> <!-- get everything -->
</xsl:template>

<xsl:template match="div2[@type='Illustration' and not(head)]">
<xsl:copy>
  <xsl:apply-templates select="@*"/> <!-- get all the attributes -->
  <head><xsl:value-of select="@n"/></head>  <!-- put @n in a head -->
  <xsl:apply-templates/> <!-- get everything -->
</xsl:copy>
</xsl:template>

<xsl:template match="@*|node()" name="default"> 
<xsl:copy>
  <xsl:apply-templates select="@*|node()|processing-instruction()|comment()"/>
</xsl:copy>
</xsl:template>

</xsl:stylesheet>