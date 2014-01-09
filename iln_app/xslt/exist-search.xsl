<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exist="http://exist.sourceforge.net/NS/exist"
  version="1.0" exclude-result-prefixes="exist">

  <xsl:output method="xml" omit-xml-declaration="yes"/>

<xsl:include href="ilnshared.xsl"/>  

<!-- construct string to pass search term values to browse via url -->
<xsl:variable name="term_string"><xsl:if test="$term != 0">&amp;term=<xsl:value-of select="$term"/></xsl:if><xsl:if test="$term2 != 0">&amp;term2=<xsl:value-of select="$term2"/></xsl:if><xsl:if test="$term3 != 0">&amp;term3=<xsl:value-of select="$term3"/></xsl:if></xsl:variable>

  <!-- information about current set of results  -->
  <xsl:variable name="position"><xsl:value-of select="//@exist:start"/></xsl:variable>
  <xsl:param name="max"/>
  <xsl:variable name="total"><xsl:value-of select="//@exist:hits"/></xsl:variable>
  <xsl:param name="term"/>
  <xsl:param name="term2"/>
<!--  <xsl:include href="ilnshared.xsl"/> -->

  <xsl:variable name="nl"><xsl:text> 
</xsl:text></xsl:variable>


<xsl:template match="/">
DEBUG:in root template
    <xsl:call-template name="itemlist"/>
  </xsl:template>

  <xsl:template name="itemlist">
    <xsl:if test="count(//div2) > 0">

    <xsl:call-template name="total-jumplist"/>
    
      <table class="browse">
        <thead style="font-size:small;">
        <tr>
          <xsl:if test="//div2/hits"><th class="hits">hits</th></xsl:if>
          <th class="num">#</th>
          <xsl:if test="//div2/head"><th>title</th></xsl:if>
          <xsl:if test="//div2/bibl"><th>date</th></xsl:if>
          <xsl:if test="//div2/@type"><th>type</th></xsl:if>
	  <xsl:if test="//div2/bibl/extent"><th># paragraphs</th></xsl:if>
      </tr>
    </thead>
    <tbody align="left" valign="top" style="font-size:small;">
      <xsl:apply-templates select="//div2"/>
    </tbody>
  </table>
</xsl:if>
  
  </xsl:template>

  <xsl:template match="div2">
    <tr>	<!-- calculate item's position in total result set -->
    <xsl:apply-templates select="hits" mode="table"/>
      <td class="num" width="4%"><xsl:value-of select="position() + $position - 1"/>.</td>
      <xsl:value-of select="$nl"/>

      <!--      <xsl:apply-templates select="*[not(self::hits)]" mode="table"/> -->

      <!-- there should ALWAYS be a table cell for a field if any of
      the records include that field (e.g., some texts that have no date) -->

      <xsl:if test="//div2/head"> 
	<td class="title"><xsl:element name="a">
	  <xsl:attribute name="href">browse.php?id=<xsl:value-of
	select="@id"/>&amp;term=<xsl:value-of select="$term"/></xsl:attribute>
	  <xsl:apply-templates select="head" mode="table"/>
	</xsl:element></td>
      </xsl:if>
      <xsl:if test="//div2/@type">
        <td class="author"  width="10%">
<xsl:apply-templates select="div2/@type" />
    </td>
      </xsl:if>
      <xsl:if test="//div2/bibl">
        <td class="date"  width="25%"><xsl:apply-templates
	select="biblScope[@type='volume']" mode="table"/><xsl:text>,
	</xsl:text><xsl:apply-templates
	select="biblScope[@type='issue']"/><xsl:text>, </xsl:text>
	<xsl:apply-templates
	    select="biblScope[@type='pages']"/><xsl:text>,
	</xsl:text><xsl:apply-templates select="date"/></td>
      </xsl:if>
    <xsl:if test="//item/subject">
        <td><xsl:apply-templates select="subject" mode="table"/></td>
      </xsl:if>
    </tr>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="item/*" mode="table">
    <xsl:if test="name() != 'id'">
      <xsl:apply-templates select="."/>
    </xsl:if>
  </xsl:template>

<!-- no kwic
  <xsl:template match="item/hits" mode="table">
    <td class="hits">
      <a>
        <xsl:attribute name="href">kwic.php?id=<xsl:value-of
	select="../id/@id"/>&amp;keyword=<xsl:value-of select="$keyword"/></xsl:attribute>
        <xsl:apply-templates select="."/>
      </a>
    </td>
    <xsl:value-of select="$nl"/>
  </xsl:template>

-->

<!-- display multiple subjects for a single text in one table cell -->
<xsl:template match="item/subject" mode="table">
  <xsl:if test="count(preceding-sibling::subject) > 0">
    <br/>
  </xsl:if>
      <xsl:apply-templates select="."/>
</xsl:template>


<!-- possibly multiple names in table mode -->
<xsl:template match="item/name">
  <a>
    <xsl:attribute name="href">search.php?author=<xsl:value-of select="normalize-space(.)"/></xsl:attribute>
    <xsl:apply-templates/>
  </a>
  <xsl:if test="position() != last()">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>


<!-- do nothing with id itself --> <xsl:template match="id"/>

<xsl:template name="total-jumplist">


  <!-- only display total & jump list if there are actually results -->
  <xsl:if test="$total > 0">

    <xsl:variable name="url">
      <xsl:choose>
        <xsl:when test="$mode = 'browse'">browse.php?field=<xsl:value-of select="$field"/><xsl:if test="$value">&amp;value=<xsl:value-of select="$value"/></xsl:if><xsl:if test="$letter">&amp;letter=<xsl:value-of select="$letter"/></xsl:if>
      </xsl:when>
      <xsl:when test="$mode = 'search'">search.php?<xsl:value-of select="$url_suffix"/></xsl:when>
    </xsl:choose>
  </xsl:variable>

  <table class="searchnav">
      <!-- always build a table with four cells so spacing will be consistent -->
      <tr>
      <xsl:choose>
        <xsl:when test="$position != 1">

          <!-- start position for previous chunk -->
        <xsl:variable name="newpos">
          <!-- start position shouldn't go below 1 -->
          <xsl:call-template name="max">
            <xsl:with-param name="num1"><xsl:value-of select="($position - $max)"/></xsl:with-param>
            <xsl:with-param name="num2"><xsl:value-of select="1"/></xsl:with-param>
          </xsl:call-template>
        </xsl:variable>

          <td>
            <!-- don't display first if it is the same as previous -->
            <xsl:if test="$newpos != 1">
              <a>
                <xsl:attribute name="href"><xsl:value-of 
                select="concat($url, '&amp;position=1&amp;max=', $max)"/></xsl:attribute>
                &lt;&lt; First
              </a>
            </xsl:if>
        </td>          


        <td>
          <a>
            <xsl:attribute name="href"><xsl:value-of 
            select="concat($url, '&amp;position=', $newpos, '&amp;max=', $max)"/></xsl:attribute>
            &lt;Previous
          </a>          
        </td>
        </xsl:when>
        <xsl:otherwise>
          <td></td>	<!-- first -->
          <td></td>	<!-- prev  -->
        </xsl:otherwise>
      </xsl:choose>

      <!-- next -->

      <xsl:variable name="next-start">
        <xsl:value-of select="($position + $max)"/>
      </xsl:variable>

      <xsl:variable name="last-start">
        <xsl:value-of select="($total - $max + 1)"/>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="($next-start - 1) &lt; $total">
          <td>
            <a>
            <xsl:attribute name="href"><xsl:value-of 
            select="concat($url, '&amp;position=', $next-start, '&amp;max=', $max)"/></xsl:attribute>
            Next&gt;
          </a>          
        </td>

        <td>
          <!-- don't display last if it is the same as next -->
          <xsl:if test="$next-start != $last-start">
            <a>
              <xsl:attribute name="href"><xsl:value-of 
              select="concat($url, '&amp;position=', $last-start, '&amp;max=', $max)"/></xsl:attribute>
              Last&gt;&gt;
            </a>          
          </xsl:if>
          
        </td>
        </xsl:when>
        <xsl:otherwise>
          <td></td>	<!-- next -->
          <td></td>	<!-- last -->
        </xsl:otherwise>
      </xsl:choose>
    </tr>
    </table>


  <xsl:variable name="chunksize"><xsl:value-of select="$max"/></xsl:variable>  
    <!-- only display jump list if there are more results than displayed here. -->
    <xsl:if test="$total > $chunksize">
      <form id="jumpnav">
        <xsl:attribute name="action"><xsl:value-of select="$mode"/>.php</xsl:attribute>
        <xsl:choose>
          <xsl:when test="$mode = 'browse'">
            <input name="field" type="hidden">
              <xsl:attribute name="value"><xsl:value-of select="$field"/></xsl:attribute>
            </input>
            <xsl:if test="$value">
              <input name="value" type="hidden">
                <xsl:attribute name="value"><xsl:value-of select="$value"/></xsl:attribute>
              </input>
            </xsl:if>
            <xsl:if test="$letter">
              <input name="letter" type="hidden">
                <xsl:attribute name="value"><xsl:value-of select="$letter"/></xsl:attribute>
              </input>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$mode = 'search'">
            <input name="keyword" type="hidden">
              <xsl:attribute name="value"><xsl:value-of select="$keyword"/></xsl:attribute>
            </input>
            <input name="author" type="hidden">
              <xsl:attribute name="value"><xsl:value-of select="$auth"/></xsl:attribute>
            </input>            <input name="doctitle" type="hidden">
              <xsl:attribute name="value"><xsl:value-of select="$doctitle"/></xsl:attribute>
            </input>            <input name="date" type="hidden">
              <xsl:attribute name="value"><xsl:value-of select="$date"/></xsl:attribute>
            </input>
            <input name="subject" type="hidden">
              <xsl:attribute name="value"><xsl:value-of select="$subject"/></xsl:attribute>
            </input>
          </xsl:when>
        </xsl:choose>
        <input name="max" type="hidden">
          <xsl:attribute name="value"><xsl:value-of select="$max"/></xsl:attribute>
        </input>
        <select name="position" onchange="submit();">
          <xsl:call-template name="jumpnav-option"/>
        </select>
      </form>
    </xsl:if> 

    <xsl:element name="p">
      <xsl:value-of select="$total"/> match<xsl:if test="$total != 1">es</xsl:if> found
    </xsl:element>
  </xsl:if> 
</xsl:template>


<!-- recursive function to generates option values for jumpnav form 
     based on position, max, and total -->
<xsl:template name="jumpnav-option">
  <!-- position, max, and total are global -->
  <xsl:param name="curpos">1</xsl:param>	<!-- start at 1 -->
  
  <xsl:variable name="curmax">    
    <xsl:call-template name="min">
      <xsl:with-param name="num1">
        <xsl:value-of select="$curpos + $max - 1"/>
      </xsl:with-param>
      <xsl:with-param name="num2">
        <xsl:value-of select="$total"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <option> 
    <xsl:attribute name="value"><xsl:value-of select="$curpos"/></xsl:attribute>
    <!-- if this option is the content currently being displayed, mark as selected -->
    <xsl:if test="$curpos = $position">
      <xsl:attribute name="selected">selected</xsl:attribute>
    </xsl:if>
    <xsl:value-of select="$curpos"/> - <xsl:value-of select="$curmax"/>
  </option>

  <!-- if the end of this section is less than the total, recurse -->
  <xsl:if test="$total > $curmax">
    <xsl:call-template name="jumpnav-option">
      <xsl:with-param name="curpos">
        <xsl:value-of select="$curpos + $max"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
