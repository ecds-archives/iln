<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:html="http://www.w3.org/TR/REC-html40" 
	xmlns:xql="http://metalab.unc.edu/xql/"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:exist="http://exist.sourceforge.net/NS/exist"
	exclude-result-prefixes="exist" version="1.0">

<xsl:include href="teihtml-tables.xsl"/>
<xsl:include href="ilnshared.xsl"/>


  <xsl:param name="term">0</xsl:param>
  <xsl:param name="term2">0</xsl:param>
  <xsl:param name="term3">0</xsl:param>
  <xsl:param name="defaultindent">5</xsl:param>

  <xsl:variable name="term_string"><xsl:if test="$term != 0">&amp;term=<xsl:value-of select="$term"/></xsl:if><xsl:if test="$term2 != 0">&amp;term2=<xsl:value-of select="$term2"/></xsl:if><xsl:if test="$term3 != 0">&amp;term3=<xsl:value-of select="$term3"/></xsl:if></xsl:variable>

  <xsl:output method="html"/>  


<xsl:template match="/"> 
<xsl:element name="div"><xsl:attribute name="class">content</xsl:attribute>
<xsl:apply-templates/>
</xsl:element>
</xsl:template>

<xsl:template match="tei:text"> 
<xsl:apply-templates select="//tei:div2" />
<!-- links to next & previous titles (if present) -->
  <xsl:call-template name="next-prev" />
</xsl:template>

<!-- print out the content-->
<xsl:template match="tei:div2">
<!-- get everything under this node -->
  <xsl:apply-templates/> 
</xsl:template>

<!-- display the title -->
<xsl:template match="tei:div2/tei:head">
  <xsl:element name="h1">
   <xsl:apply-templates />
  </xsl:element>
</xsl:template>

<xsl:template match="tei:head/@type['sub']">
  <xsl:element name="h2">
   <xsl:apply-templates />
  </xsl:element>
</xsl:template>

<xsl:template match="tei:bibl">
  <xsl:element name="i">
    <xsl:value-of select="tei:title"/>,
  </xsl:element>
  <xsl:value-of select="tei:biblScope[@type='volume']"/>,
  <xsl:value-of select="tei:biblScope[@type='issue']"/>,
  <xsl:value-of select="tei:biblScope[@type='pages']"/>.<br/>
<!-- date information seems redundant for some articles... -->
   <p><xsl:value-of select="tei:date"/></p>
</xsl:template>

<xsl:template match="tei:p/tei:title">
  <xsl:element name="i">
    <xsl:apply-templates />
  </xsl:element>
</xsl:template>  

<xsl:template match="tei:p">
  <xsl:element name="p">
    <xsl:apply-templates /> 
  </xsl:element>
</xsl:template>

<xsl:template match="tei:q">
  <xsl:element name="blockquote">
    <xsl:apply-templates /> 
  </xsl:element>
</xsl:template>

<xsl:template match="tei:q/@rend['blockquote']">
  <xsl:element name="blockquote">
    <xsl:apply-templates /> 
  </xsl:element>
</xsl:template>

<!-- show page breaks -->
<xsl:template match="tei:pb">
  <hr class="pb"/>
    <p class="pagebreak">
      Page <xsl:value-of select="@n"/>
</p>
</xsl:template>

<!-- convert rend tags to their html equivalents 
     so far, converts: center, italic,smallcaps   -->
<xsl:template match="//*[@rend]">
  <xsl:choose>
    <xsl:when test="@rend='center'">
      <xsl:element name="center">
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@rend='italic'">
      <xsl:element name="i">
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@rend='smallcaps'">
      <xsl:element name="span">
        <xsl:attribute name="class">smallcaps</xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@rend='smallcap'">
      <xsl:element name="span">
        <xsl:attribute name="class">smallcaps</xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@rend='right'">
      <xsl:element name="div">
        <xsl:attribute name="class">right</xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@rend='superscript'">
      <xsl:element name="span">
        <xsl:attribute name="class">superscript</xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>

  </xsl:choose>
</xsl:template>

<xsl:template match="tei:lb">
  <xsl:element name="br" />
</xsl:template>

<!-- sic : show 'sic' as an editorial comment -->
<xsl:template match="tei:sic">
  <xsl:apply-templates select="text()"/>
  <!-- show the text between the sic tags -->
  <xsl:element name="span">
    <xsl:attribute name="class">editorial</xsl:attribute>
	[sic]
  </xsl:element>
</xsl:template>


<!-- line group -->
<xsl:template match="tei:lg">
  <xsl:element name="p">
     <xsl:attribute name="class"><xsl:value-of select="@type"/></xsl:attribute>
    <xsl:apply-templates />
  </xsl:element>
</xsl:template>

<!-- line  -->
<!--   Indentation should be specified in format rend="indent#", where # is
       number of spaces to indent.  --> 
<xsl:template match="tei:l">
  <!-- retrieve any specified indentation -->
  <xsl:if test="@rend">
  <xsl:variable name="rend">
    <xsl:value-of select="./@rend"/>
  </xsl:variable>
  <xsl:variable name="indent">
     <xsl:choose>
       <xsl:when test="$rend='indent'">		
	<!-- if no number is specified, use a default setting -->
         <xsl:value-of select="$defaultindent"/>
       </xsl:when>
       <xsl:otherwise>
         <xsl:value-of select="substring-after($rend, 'indent')"/>
       </xsl:otherwise>
     </xsl:choose>
  </xsl:variable>
   <xsl:call-template name="indent">
     <xsl:with-param name="num" select="$indent"/>
   </xsl:call-template>
 </xsl:if>

  <xsl:apply-templates/>
  <xsl:element name="br"/>
</xsl:template>
<!-- generate next & previous links (if present) -->
<!-- note: all div2s, with id, head, and bibl are retrieved in a <siblings> node -->
<xsl:template name="next-prev">

<xsl:element name="table">
  <xsl:attribute name="width">100%</xsl:attribute>

<!-- display articles relative to position of current article -->
<xsl:element name="tr">
<xsl:if test="//prev/@xml:id">
<xsl:element name="th">
    <xsl:text>Previous: </xsl:text>
</xsl:element>
<xsl:element name="td">
 <xsl:element name="a">
   <xsl:attribute name="href">browse.php?id=<xsl:value-of
		select="//prev/@xml:id"/></xsl:attribute>
   <xsl:apply-templates select="//prev/@n"/>
 </xsl:element><!-- end a -->
</xsl:element> <!-- end td -->
<xsl:element name="td"><xsl:apply-templates select="//prev/@type"></xsl:apply-templates></xsl:element><!-- end td -->
<xsl:element name="td"> <xsl:attribute name="valign">top</xsl:attribute>
  <xsl:element name="font">
   <xsl:attribute name="size">-1</xsl:attribute> 
  <xsl:value-of select="//prev/tei:bibl/tei:biblScope[@type='volume']"/>,
  <xsl:value-of select="//prev/tei:bibl/tei:biblScope[@type='issue']"/>,
  <xsl:value-of select="//prev/tei:bibl/tei:biblScope[@type='pages']"/>.
  (<xsl:value-of select="//prev/tei:bibl/tei:extent"/>) 
  </xsl:element> <!-- font -->
</xsl:element><!-- end td -->
</xsl:if>
</xsl:element><!-- end  prev row --> 

<xsl:element name="tr">
<xsl:if test="//next/@xml:id">
<xsl:element name="th">
    <xsl:text>Next: </xsl:text>
</xsl:element>
<xsl:element name="td">
 <xsl:element name="a">
   <xsl:attribute name="href">browse.php?id=<xsl:value-of
		select="//next/@xml:id"/></xsl:attribute>
   <xsl:apply-templates select="//next/@n"/>
 </xsl:element><!-- end a -->
</xsl:element>
<xsl:element name="td"><xsl:apply-templates select="//next/@type"></xsl:apply-templates></xsl:element><!-- end td -->
<xsl:element name="td"> <xsl:attribute name="valign">top</xsl:attribute>
  <xsl:element name="font">
   <xsl:attribute name="size">-1</xsl:attribute> 
  <xsl:value-of select="//next/tei:bibl/tei:biblScope[@type='volume']"/>,
  <xsl:value-of select="//next/tei:bibl/tei:biblScope[@type='issue']"/>,
  <xsl:value-of select="//next/tei:bibl/tei:biblScope[@type='pages']"/>.
  (<xsl:value-of select="//next/tei:bibl/tei:extent"/>) 
  </xsl:element> <!-- font -->
</xsl:element><!-- end td -->
</xsl:if>
</xsl:element><!-- end  next row --> 
<xsl:element name="tr">
  <xsl:element name="th"><xsl:text>Article List for: </xsl:text></xsl:element>
  <xsl:element name="td"><xsl:element name="a">
	  <xsl:attribute
	      name="href">volume.php?id=<xsl:value-of
	      select="//issueid/@xml:id"/></xsl:attribute><xsl:value-of
	      select="//issueid/tei:head"/> </xsl:element><!-- end a -->
  </xsl:element> <!-- end td -->
  <xsl:element name="td"/> <!-- empty td -->
</xsl:element> <!-- end tr -->
</xsl:element> <!-- table -->
</xsl:template>


<!-- 
<xsl:template name="return">
      <xsl:element name="p">
	Go to Article List for <xsl:element name="a">
	  <xsl:attribute
	      name="href">volume.php?id=<xsl:value-of
	      select="//issueid/@id"/></xsl:attribute><xsl:value-of select="//issueid/head"/> 
</xsl:element>  
</xsl:element> 

</xsl:template>-->
<!-- mark exist matches for highlighting -->
  <xsl:template match="exist:match">
    <span class="match"><xsl:apply-templates/></span>
  </xsl:template>

  <!-- recursive template to indent by inserting non-breaking spaces -->
  <xsl:template name="indent">
    <xsl:param name="num">0</xsl:param>
    <xsl:variable name="space">&#160;</xsl:variable>
    
    <xsl:value-of select="$space"/>
    
    <xsl:if test="$num > 1">
      <xsl:call-template name="indent">
        <xsl:with-param name="num" select="$num - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>