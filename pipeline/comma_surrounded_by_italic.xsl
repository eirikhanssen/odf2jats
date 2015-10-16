<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[following-sibling::italic and preceding-sibling::italic][parent::ref]">
        <xsl:choose>
            <xsl:when test="matches(. , '^\s*(,|\.|;|:)\s*$')">
                <italic><xsl:value-of select="."/></italic>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>