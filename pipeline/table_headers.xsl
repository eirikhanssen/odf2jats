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

    <!-- if a td has a table_header child, then it should be a th-element -->
    
    <xsl:template match="td[table_header]">
        <th><xsl:apply-templates/></th>
    </xsl:template>
    
    <xsl:template match="td[table_header_row|table_header_scope_row]">
        <th scope="row"><xsl:apply-templates/></th>
    </xsl:template>
    
    <xsl:template match="td[table_header_col|table_header_scope_col]">
        <th scope="col"><xsl:apply-templates/></th>
    </xsl:template>
    
    <xsl:template match="table_header|table_header_scope_col|table_header_scope_row">
        <p><xsl:apply-templates/></p>
    </xsl:template>
</xsl:stylesheet>