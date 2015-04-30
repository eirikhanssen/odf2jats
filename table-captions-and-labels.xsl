<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="table-wrap/label">
        <xsl:variable name="first_preceding_element" select="../preceding-sibling::element()[1]"/>
        <xsl:variable name="second_preceding_element" select="../preceding-sibling::element()[2]"/>
        <xsl:choose>
            <xsl:when test="local-name($first_preceding_element) = 'table_label'">
                <label><xsl:apply-templates select="$first_preceding_element" mode="appendix"/></label>
            </xsl:when>
            <xsl:when test="local-name($first_preceding_element) = 'table_label' or (local-name($first_preceding_element) = 'table_caption' and local-name($second_preceding_element) = 'table_label')">
                <label><xsl:value-of select="$second_preceding_element"/></label>
            </xsl:when>
            <xsl:otherwise>
                <label>___</label>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="table-wrap/caption">
        <xsl:variable name="first_preceding_element" select="../preceding-sibling::element()[1]"/>
        <xsl:variable name="second_preceding_element" select="../preceding-sibling::element()[2]"/>
        <xsl:choose>
            <xsl:when test="local-name($first_preceding_element) = 'table_caption'">
                <caption><p><xsl:apply-templates select="$first_preceding_element" mode="appendix"/></p></caption>
            </xsl:when>
            <xsl:when test="local-name($first_preceding_element) = 'table_caption' or (local-name($first_preceding_element) = 'table_label' and local-name($second_preceding_element) = 'table_caption')">
                <caption><p><xsl:apply-templates select="$second_preceding_element" mode="appendix"/></p></caption>>
            </xsl:when>
            <xsl:otherwise>
                <caption><p>___</p></caption>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="table_label|table_caption"/>

    <xsl:template match="table_caption|table_label" mode="appendix">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- Default template for all modes-  do an identity transform and copy over the node unchanged -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>