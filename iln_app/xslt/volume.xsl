<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:html="http://www.w3.org/TR/REC-html40" 
    xmlns:xql="http://metalab.unc.edu/xql/"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:exist="http://exist.sourceforge.net/NS/exist"
    exclude-result-prefixes="exist" version="1.0">

    <xsl:output method="html"/>  
    
    <xsl:template match="/"> 
        <xsl:element name="div"><xsl:attribute name="class">content</xsl:attribute>
            <xsl:apply-templates select="//tei:div1"/>
        </xsl:element>
    </xsl:template>
   
    <!-- process the volume -->
    <xsl:template match="tei:div1">
       <xsl:apply-templates select="//tei:div1/tei:head"/>
       <xsl:apply-templates select="//tei:div2"/>
   </xsl:template>

    <!-- display the volume title -->
    <xsl:template match="tei:div1/tei:head">
        <xsl:element name="h2">
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <!-- process the article -->
    <xsl:template match="tei:div2">
        <xsl:element name="li">
            <xsl:attribute name="class">contents</xsl:attribute>
            <xsl:element name="a">
                <xsl:attribute name="href">../../browse/<xsl:value-of select="@xml:id"/></xsl:attribute>
        <xsl:apply-templates select="tei:head"/>
            </xsl:element>
            <xsl:text> - </xsl:text><xsl:value-of select="@type"/><xsl:text> - </xsl:text><xsl:value-of select="tei:bibl/tei:date"/><xsl:text> - (</xsl:text><xsl:value-of select="tei:bibl/tei:extent"/><xsl:text>)</xsl:text>
        </xsl:element>
        <xsl:apply-templates select="descendant::tei:figure"/>
    </xsl:template>
  
    <!-- display figure & link to image -->
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
                    <xsl:attribute name="class">figure</xsl:attribute>                  
                        <xsl:element name="a">
                            <xsl:attribute name="href">../../illustration/<xsl:value-of select="$fig_value"/></xsl:attribute>
                            <xsl:attribute name="target">_blank</xsl:attribute>
                            <!-- open a new window without javascript -->
                            <xsl:element name="img">
                                <xsl:attribute name="src">http://beck.library.emory.edu/iln/image-content/ILN<xsl:value-of select="$fig_id"/>.gif</xsl:attribute>
                                <xsl:attribute name="alt">view image</xsl:attribute>
                            </xsl:element> <!-- end img -->
                        </xsl:element> <!-- end a --> 
                </xsl:element> <!-- end td -->
                
                <xsl:element name="td">
                    <xsl:element name="p">
                        <xsl:attribute name="class">caption</xsl:attribute>
                        <xsl:value-of select="tei:head"/>
                <xsl:element name="br"/>
                <xsl:element name="font">
                    <xsl:attribute name="size">-1</xsl:attribute>
                    <xsl:value-of select="preceding::tei:biblScope[@type='volume'][1]"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="preceding::tei:biblScope[@type='issue'][1]"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="preceding::tei:biblScope[@type='pages'][1]"/>
                    <xsl:text>. </xsl:text>
                    <xsl:value-of select="preceding::tei:date[1]"/>
                </xsl:element>
                    
                </xsl:element> <!-- end td -->
            </xsl:element> <!-- end tr --> 
        </xsl:element>  <!-- end table -->
        </xsl:element>
    </xsl:template>
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
    
</xsl:stylesheet>