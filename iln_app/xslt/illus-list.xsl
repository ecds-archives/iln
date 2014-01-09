<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exist="http://exist.sourceforge.net/NS/exist"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  version="1.0" exclude-result-prefixes="exist">

  <xsl:output method="xml" omit-xml-declaration="yes"/>

  <xsl:param name="mode"/>	 <!-- illus-list -->
  
  <!-- search terms -->
  <xsl:param name="id"/>
  <xsl:param name="date"/>
  <xsl:param name="keyword"/>
  <xsl:param name="type"/>
  <xsl:param name="max"/>
  
  <xsl:variable name="url_suffix"><xsl:if test="$id">id=<xsl:value-of select="$id"/></xsl:if><xsl:if test="$keyword">keyword=<xsl:value-of select="$keyword"/></xsl:if><xsl:if test="$date">&amp;date=<xsl:value-of select="$date"/></xsl:if></xsl:variable>
  
  <!-- information about current set of results  -->
  <xsl:variable name="position"><xsl:value-of select="//@exist:start"/></xsl:variable>
  
  <xsl:variable name="total"><xsl:value-of select="//@exist:hits"/></xsl:variable>
  
<xsl:variable
    name="image_url">http://beck.library.emory.edu/iln/image-content/</xsl:variable>

<xsl:variable name="nl"><xsl:text> 
</xsl:text></xsl:variable>
  
<xsl:template match="/">
<!-- <xsl:text>DEBUG: root template matched!</xsl:text> -->
  <xsl:call-template name="itemlist"/>
<!--  <xsl:element name="table">  
    <xsl:apply-templates/>
  </xsl:element> -->
</xsl:template> 

  <xsl:template name="itemlist">
    
    <xsl:if test="$total > 0">
            <p class="info">Click on the title to view the whole article.<br/>
        Click on the thumbnail to view the image.</p>      
      <xsl:call-template name="total-jumplist"/>     
      <table class="browse">
        <thead style="font-size:small;">
          <tr>
            <th class="num">#</th>
            <th>image</th>
            <th>title and date</th>
          </tr>
        </thead>
        <tbody align="left" valign="top" style="font-size:small;">
          <xsl:apply-templates select="//div2"/>
        </tbody>
      </table>
    </xsl:if>
    
  </xsl:template>
  

<xsl:template match="div2">
  <tr class="item">	<!-- calculate item's position in total result set -->

      <xsl:apply-templates select="hits" mode="table"/>
    <td class="num" width="4%"><xsl:value-of select="position() + $position - 1"/>.</td>
    <xsl:value-of select="$nl"/>
    
<!--    <xsl:attribute name="class">item</xsl:attribute>-->
    <xsl:call-template name="thumb"/>
    <xsl:call-template name="biblio"/>
 </tr>
</xsl:template>

<xsl:template name="biblio">
  <xsl:element name="td">
    <xsl:attribute name="class">title</xsl:attribute>
    <xsl:element name="a">
	  <xsl:attribute name="href">browse.php?id=<xsl:value-of
	select="@xml:id"/></xsl:attribute>
	      <xsl:apply-templates select="figure/tei:head" mode="table"/>
    </xsl:element> <!-- end a -->
      
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
        <xsl:element name="br"/> 
	  <xsl:if test="@type='Article'">
	    <xsl:text>Article title: </xsl:text>
	    <xsl:apply-templates select="tei:head"/>
	  </xsl:if>
  </xsl:element> <!-- end font --></xsl:element>
</xsl:template>


<!--display figure & link to image-viewer  (slightly different than ilnshared) -->
<xsl:template name="thumb">
<xsl:variable name="fig_value" select="figure/@url"/>
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
      <!-- <xsl:element name="tr"> -->
      <!-- <xsl:variable name="image_id"><xsl:value-of select="$fig_id"/></xsl:variable> -->
        <xsl:element name="td">
          <xsl:attribute name="class">figure</xsl:attribute>

<!-- javascript version of the image & link -->

      <xsl:element name="a">
	<xsl:attribute
name="href">javascript:launchViewer('figure.php?id=<xsl:value-of select="$fig_value"/>')</xsl:attribute>

<xsl:element name="img">
  <xsl:attribute name="class">javascript</xsl:attribute>
  <xsl:attribute name="src"><xsl:value-of select="concat($image_url, 'ILN', $fig_id, '.gif')"/></xsl:attribute>
  <xsl:attribute name="alt">view image</xsl:attribute>
  <xsl:attribute name="title"><xsl:value-of select="normalize-space(tei:head)"/></xsl:attribute>
  </xsl:element> <!-- end img -->
  </xsl:element> <!-- end a --> 


<!-- non-javascript version of image & link -->
<!-- note: if neither javascript nor css works, there will be two
   copies of image (but other things will probably be broken also) -->
  <noscript>
      <xsl:element name="a">
<!--  <xsl:attribute name="href"><xsl:value-of
select="concat($image_url, 'ILN', @entity, '.jpg')"/></xsl:attribute> -->
	<xsl:attribute name="href">figure.php?id=<xsl:value-of select="$fig_value"/></xsl:attribute>
        <xsl:attribute name="target">web/image_viewer</xsl:attribute>
        <!-- open a new window without javascript -->
  <xsl:element name="img"> 


  <xsl:attribute name="src"><xsl:value-of select="concat($image_url, 'ILN', $fig_id, '.gif')"/></xsl:attribute>
  <xsl:attribute name="alt">view image</xsl:attribute>
  </xsl:element> <!-- end img -->
  </xsl:element> <!-- end a --> 
 </noscript> 

  </xsl:element> <!-- end td -->
</xsl:template>

  <xsl:template name="total-jumplist">
    
    
    <!-- only display total & jump list if there are actually results -->
    <xsl:if test="$total > 0">
      
      <xsl:variable name="url"><xsl:value-of select="concat($mode, '.php?', $url_suffix)"/>
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

              <input name="id" type="hidden">
                <xsl:attribute name="value"><xsl:value-of select="$id"/></xsl:attribute>
              </input>

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
  <!-- return the smaller of two numbers -->
  <xsl:template name="min">
    <xsl:param name="num1"/>
    <xsl:param name="num2"/>
    
    <xsl:choose>
      <xsl:when test="$num1 > $num2">
        <xsl:value-of select="$num2"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$num1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- return the larger of two numbers -->
  <xsl:template name="max">
    <xsl:param name="num1"/>
    <xsl:param name="num2"/>
    <xsl:choose>
      <xsl:when test="number($num1) > number($num2)">
        <xsl:value-of select="$num1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$num2"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

</xsl:stylesheet>
