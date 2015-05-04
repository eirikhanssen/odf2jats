<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="text()" priority="2">
        <xsl:analyze-string select="." regex="((\c+)\s*[,]\s*(et\sal\.,\s*)(([(]?| *?)?\d{{4}}\c?[)]?)?)">
            <xsl:matching-substring>
                <xsl:message>
                    <xsl:text>autocorrections.xsl: removed «,» &#xa;</xsl:text>
                    <xsl:text>&#x09; From: «</xsl:text><xsl:value-of select="regex-group(1)"/><xsl:text>» To: «</xsl:text>
                    <xsl:value-of select="concat(regex-group(2) , ' ' , regex-group(3), regex-group(4))"/><xsl:text>»</xsl:text>
                </xsl:message>
                <xsl:value-of select="normalize-space(concat(regex-group(2) , ' ' , regex-group(3), regex-group(4)))"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:copy/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <!-- Default template for all modes-  do an identity transform and copy over the node unchanged -->
    <xsl:template match="node()|@*" priority="1">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>