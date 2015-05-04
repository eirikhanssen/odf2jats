<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:o2j="https://github.com/eirikhanssen/odf2jats"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="xs o2j">

    <xsl:output method="xml" indent="yes"/>
    <!-- 
        Store all refs with element-citation in a variable for comparing et al. type citations against 
        referencs in the ref-list 
    -->
    <xsl:variable name="element-citation-refs" select="/article/back/ref-list/ref[element-citation]"/>
    
    <xsl:template match="element()[not(ancestor::ref-list)]/text()">
        <xsl:analyze-string select="." regex="(((\c+)\s+(et\s+al\.|and\s+colleagues)\s+)\((\d{{4}}\c?)\))">
            <xsl:matching-substring>
                <xsl:variable name="authorSurname" select="regex-group(3)"/>
                <xsl:variable name="yearString" select="regex-group(5)"/>
                
                <xsl:variable name="rid">
                    <xsl:choose>
                        <!-- 
                            If there is one and only one ref in the ref-list where the first author's surname and the year matches the 
                            surname and year in an et al. citation, then copy the id from that ref in the ref-list to the rid-attribute 
                            in this xref element. 
                        -->
                        <xsl:when test="count($element-citation-refs[(matches(element-citation/person-group[1]/name[1]/surname , $authorSurname)) and element-citation/year = $yearString]) = 1">
                            <xsl:value-of select="$element-citation-refs[(matches(element-citation/person-group[1]/name[1]/surname , $authorSurname)) and element-citation/year = $yearString]/@id"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(replace($authorSurname, '\C', '') , '  ' , $yearString)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xref>
                    <xsl:attribute name="ref-type">bibr</xsl:attribute>
                    <xsl:attribute name="rid" select="$rid"/>
                    <xsl:value-of select="regex-group(1)"/>
                </xref>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:copy/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template match="/element()">
        <xsl:element name="{name(.)}">
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="document('')/*/namespace::*[name()='xlink']"/>
            <xsl:copy-of select="document('')/*/namespace::*[name()='xsi']"/>
            <xsl:copy-of select="document('')/*/namespace::*[name()='mml']"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- Default template for all modes-  do an identity transform and copy over the node unchanged -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
