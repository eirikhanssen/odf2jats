<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="fig">
        <fig>
            <xsl:attribute name="id">
                <xsl:value-of select="concat('fig', count(preceding::fig) +1)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </fig>
    </xsl:template>

    <xsl:template match="graphic">
        <graphic>
            <xsl:attribute name="id">
                <xsl:value-of select="concat('graphic', count(preceding::graphic) +1)"/>
            </xsl:attribute><xsl:copy-of select="@*"/>
        </graphic>
    </xsl:template>

</xsl:stylesheet>