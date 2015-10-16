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
    
    <xsl:template match="node()|@*" mode="figure">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="figure_with_label_caption_graphic/text()" mode="figure"/>
    
    <xsl:template match="figure_with_label_caption_graphic">
        <fig>
            <xsl:comment>
                <xsl:for-each select="child::text()">
                    <xsl:value-of select="normalize-space(.)"></xsl:value-of>
                </xsl:for-each>
            </xsl:comment>
            <xsl:apply-templates mode="figure"/>
        </fig>
    </xsl:template>
    
</xsl:stylesheet>