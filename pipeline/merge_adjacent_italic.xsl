<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:strip-space elements="ref"/>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()[1]|@*"/>
        </xsl:copy>
        <xsl:apply-templates select="following-sibling::node()[1]"/>
    </xsl:template>
    
    <xsl:template match="italic">
        <italic>
            <xsl:call-template name="merge"/>
        </italic>
        <xsl:apply-templates select="following-sibling::node()[not(self::italic)][1]"/>
    </xsl:template>

    <xsl:template match="node()" mode="merge"/>

    <xsl:template match="italic" name="merge" mode="merge" >
        <xsl:apply-templates select="node()[1]"/>
        <xsl:apply-templates select="following-sibling::node()[1]" mode="merge"/>
    </xsl:template>

</xsl:stylesheet>