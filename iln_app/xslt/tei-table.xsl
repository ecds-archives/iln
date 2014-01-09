<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <xsl:template match="table">
    <table>
      <xsl:apply-templates select="@rend"/>
      <xsl:apply-templates/>
    </table>
  </xsl:template>

  <xsl:template match="table/@rend">
    <xsl:attribute name="class">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="table/head">
    <caption>
      <xsl:apply-templates/>
    </caption>
  </xsl:template>

  <xsl:template match="table/row">
    <tr>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>

  <xsl:template match="cell[@role='label']">
    <th>
      <xsl:apply-templates/>
    </th>
  </xsl:template>

  <xsl:template match="cell[@role='data'] | cell[not(@role)]">
    <td>
      <xsl:if test="@rows">
        <xsl:attribute name="rowspan"><xsl:value-of select="@rows"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@cols">
        <xsl:attribute name="colspan"><xsl:value-of select="@cols"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

</xsl:stylesheet>
