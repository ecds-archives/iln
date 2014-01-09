<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exist="http://exist.sourceforge.net/NS/exist"
  exclude-result-prefixes="exist" version="1.0">

  <xsl:include href="utils.xsl"/>
  <xsl:include href="tei-table.xsl"/>

  <xsl:param name="url_suffix"/>
  <xsl:variable name="myurlsuffix"><xsl:if test="$url_suffix != ''">&amp;<xsl:value-of select="$url_suffix"/></xsl:if></xsl:variable>

  <xsl:template match="teiHeader">
    <xsl:apply-templates select="//titleStmt/title"/>
    <xsl:apply-templates select="//relative-toc"/>
    <xsl:apply-templates select="//titleStmt/author"/>
    <p>
      <xsl:apply-templates select="//sourceDesc"/>
      <xsl:apply-templates select="//rs[@type='collection']"/>
    </p>
    <xsl:call-template name="doclinks"/>
  </xsl:template>


  <xsl:template match="sourceDesc">
      date: <xsl:apply-templates select="bibl/date"/>
      <br/>
      source publisher: <xsl:apply-templates select="bibl/publisher"/>
  </xsl:template>

  <xsl:template name="doclinks">
    <div class="doclinks">

      <xsl:if test="$mode = 'toc'">
        <p>
          <a>
            <xsl:attribute name="href">teiheader.php?id=<xsl:value-of select="$id"/></xsl:attribute>
            <xsl:attribute name="target">teiheader</xsl:attribute>
            more information about this document
          </a>
        </p>
      </xsl:if>

      <xsl:call-template name="printview"/>

    </div>
  </xsl:template>

  <!-- generate link to print view of current content -->
  <xsl:template name="printview">
    <p>
      <a>
        <xsl:attribute name="href"><xsl:value-of select="$url"/>&amp;view=print</xsl:attribute>
        <xsl:attribute name="target">printview</xsl:attribute>	<!-- open in a new window -->
        Print
      </a>
    </p>
  </xsl:template>


  <!-- title links back to TOC when not at TOC view -->
  <xsl:template match="titleStmt/title">
    <h1>
      <xsl:choose>
        <xsl:when test="$mode = 'toc'">
          <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
          <a>
            <xsl:attribute name="href">toc.php?id=<xsl:value-of select="//doc"/><xsl:value-of select="$myurlsuffix"/></xsl:attribute>
            <b><xsl:apply-templates/></b>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </h1>
</xsl:template>

<xsl:template match="titleStmt/author">
  <p>by <xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="author/name">
  <a>
    <xsl:attribute name="href">browse.php?field=author&amp;value=<xsl:value-of select="normalize-space(.)"/></xsl:attribute>
    <xsl:apply-templates/>
  </a>

  <!-- if the regularized version of author name is different, display it -->
  <xsl:if test="@reg != .">
  [<a>
    <xsl:attribute name="href">browse.php?field=author&amp;value=<xsl:value-of select="normalize-space(@reg)"/></xsl:attribute>
    <xsl:value-of select="@reg"/>
  </a>]
  </xsl:if>
  
</xsl:template>

<xsl:template match="rs[@type='collection']">
  <!-- texts may belong to more than one collection -->
  <xsl:choose>
    <xsl:when test="position() = 1">
      <br/>collection<xsl:if test="following-sibling::rs[@type='collection']">s</xsl:if>
      	<xsl:text>: </xsl:text> 
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>, </xsl:text>      
    </xsl:otherwise>
  </xsl:choose>

  <!-- FIXME: collection name should probably link to front page of collection; 
	- how to generate link so it will work in any collection (relative to hostname?)
 	- will need to switch between collection name (as tagged) and url version of collection name
	-->
    <xsl:apply-templates/>

</xsl:template>


<xsl:template match="subject|publisher">
  <xsl:if test="preceding-sibling::publisher">
    <xsl:text>; </xsl:text>
  </xsl:if>
  <!-- convert special characters to url format -->
  <xsl:variable name="urlval">
    <xsl:call-template name="replace-string">
      <xsl:with-param name="string"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
      <xsl:with-param name="from">&amp;</xsl:with-param>
      <xsl:with-param name="to">%26</xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <a>
    <xsl:attribute name="href">browse.php?field=<xsl:value-of select="name()"/>&amp;value="<xsl:value-of select="$urlval"/>"</xsl:attribute>
    <xsl:apply-templates/>
  </a>
</xsl:template>

<!-- display date, link to a date search -->
<xsl:template match="bibl/date">
  <xsl:variable name="searchdate">
    <xsl:choose>
      <!-- uncertain dates are in this format: [186-?]; search for all 1860 matches -->
      <xsl:when test="contains(., '?')">
        <xsl:value-of select="substring-before(substring-after(., '['), '-')"/>*
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <a>
    <xsl:attribute name="href">search.php?date=<xsl:value-of select="$searchdate"/></xsl:attribute>
    <xsl:apply-templates/>
  </a>
</xsl:template>

<!-- table of contents, relative table of contents at item view level -->


<!-- <xsl:template match="relative-toc/item|TEI.2/item|item[@name='text' and parent='group']|toc/item">  -->
<xsl:template match="node[ancestor::toc] | node[ancestor::relative-toc] | node[ancestor::kwic]">  
<xsl:choose>
  <!-- nodes that don't display, and whose children shouldn't be indented -->
  <xsl:when test="@name = 'TEI.2' or @name='body' or @name='group'"> 
    <xsl:apply-templates select="node"/>
  </xsl:when>
  <xsl:when test="@name = 'text' and (parent::node/@name != 'group' or parent::toc)">
    <xsl:apply-templates select="node"/>
  </xsl:when>
  <xsl:otherwise>

    <xsl:variable name="label">
      <xsl:call-template name="toc-label"/>
    </xsl:variable>

    <li>
      <xsl:choose>
        <!-- if this is the currently displayed node, don't make it a link -->
        <xsl:when test="@id = //content/*/@id">	<!-- could be div or titlePage -->
          <xsl:value-of select="$label"/>
        </xsl:when>
        <xsl:when test="@id = $id">
          <!-- this is the current node (may be displaying first content-level item under this node) -->
          <xsl:value-of select="$label"/>
        </xsl:when>
        <xsl:otherwise>
          <a>
            <xsl:attribute name="href">content.php?level=<xsl:value-of select="@name"/>&amp;id=<xsl:value-of select="@id"/><xsl:value-of select="$myurlsuffix"/></xsl:attribute>
            <xsl:value-of select="$label"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>


      <xsl:if test="$mode = 'kwic'">  <!-- keyword in context -->
        <xsl:apply-templates select="context"/>
      </xsl:if>

        <!-- in full TOC, only show one level in the back & front matter -->
        <xsl:if test="$mode != 'toc' or (parent::node/@name != 'back' and parent::node/@name != 'front')"> 
          <!-- if there are nodes under this one, display them now -->
            <xsl:if test="count(./node) > 0">
              <ul>
                <xsl:apply-templates select="node"/>
              </ul>
          </xsl:if>
       </xsl:if>

    </li>

    
  </xsl:otherwise>
</xsl:choose>

  </xsl:template>


  <!-- generate nice display name for toc node -->
  <xsl:template name="toc-label">
    <xsl:param name="mode"/>
      <xsl:choose>
        <xsl:when test="@name = 'front'">front matter</xsl:when>
        <xsl:when test="@name = 'back'">back matter</xsl:when>
        <xsl:when test="@name = 'titlePage'">
          title page
          <xsl:if test="@type">
            : <xsl:value-of select="@type"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="@name = 'text' and parent::node/@name='group'">
        <!-- texts under group (composite text) : display title from titlepage -->
        <xsl:apply-templates select="titlePart"/>
      </xsl:when>
      <xsl:when test="@name = 'div'">
        <!-- only display type if it is not duplicated in the head (e.g., chapter) -->
        <xsl:if test="not(contains(
                      translate(head,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),
                      translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')))">
          <xsl:value-of select="@type"/>
          <xsl:if test="head"><xsl:text>: </xsl:text></xsl:if>
        </xsl:if>
        <xsl:if test="head != ''">	<!-- a couple of the outer, wrapping divs are blank -->
          <xsl:choose>
            <xsl:when test="$mode = 'breadcrumb'">
              <xsl:apply-templates select="head" mode="short-toc"/> 
            </xsl:when>        
            <xsl:otherwise>
              <xsl:apply-templates select="head" mode="toc"/> 
            </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- formatting for well-tagged critical bibliography -->
  <xsl:template match="div[@type='bibliography']/bibl|div[@type='Section']/bibl">
    <xsl:element name="p">
      <xsl:attribute name="class">bibliography</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- article title -->
  <xsl:template match="title[@level='a']">
    <xsl:choose>
      <xsl:when test="following-sibling::title[@level='m']">
        <xsl:text>"</xsl:text><xsl:apply-templates/><xsl:text>"</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <i><xsl:apply-templates/></i>
      </xsl:otherwise>
    </xsl:choose>
    <!-- in either case, add a space after -->
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- monograph title -->
  <xsl:template match="title[@level='m']">
    <i><xsl:apply-templates/></i> 
    <xsl:text> </xsl:text>
  </xsl:template>


  <xsl:template match="div[@type='bibliography' or @type='Bibliography']//author">
    <xsl:apply-templates/>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="div[@type='bibliography' or @type='Bibliography']//date">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="div[@type='bibliography' or @type='Bibliography']//publisher">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="div[@type='bibliography' or @type='Bibliography']//pubPlace">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="div[@type='bibliography' or @type='Bibliography']//edition">
    <xsl:apply-templates/><xsl:text> </xsl:text>
  </xsl:template>


  <!-- |div[@type='bibliography']//publisher|div[@type='bibliography']//pubPlace -->


  <xsl:template match="head" mode="short-toc">
    <xsl:choose>
      <xsl:when test="seg[@type='short-title']">
        <xsl:apply-templates select="seg" mode="toc"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="toc"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- convert line breaks into spaces when building TOC -->
  <xsl:template match="head/lb|head/milestone" mode="toc">
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- don't display footnotes or footnote marks in TOC -->
  <xsl:template match="head/note|head/ref" mode="toc"/>


  <xsl:template match="exist:match">
    <span class="match"><xsl:apply-templates/></span>
  </xsl:template>


</xsl:stylesheet>
