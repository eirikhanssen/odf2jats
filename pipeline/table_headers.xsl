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

    <xsl:template match="td[table_header_scope_col_colspan2]">
        <th scope="col" colspan="2"><xsl:apply-templates/></th>
    </xsl:template>
    
    <xsl:template match="td[table_header_scope_col_colspan3]">
        <th scope="col" colspan="3"><xsl:apply-templates/></th>
    </xsl:template>
    
    <xsl:template match="td[table_header_scope_col_colspan4]">
        <th scope="col" colspan="4"><xsl:apply-templates/></th>
    </xsl:template>
    
    <xsl:template match="td[table_header_scope_row_rowspan2]">
        <th scope="row" rowspan="2"><xsl:apply-templates/></th>
    </xsl:template>
    
    <xsl:template match="td[table_header_scope_row_rowspan3]">
        <th scope="row" rowspan="3"><xsl:apply-templates/></th>
    </xsl:template>
    
    <xsl:template match="td[table_header_scope_row_rowspan4]">
        <th scope="row" rowspan="4"><xsl:apply-templates/></th>
    </xsl:template>

    <xsl:template match="table_header|table_header_scope_col|table_header_scope_row|
        table_header_scope_col_colspan2|table_header_scope_col_colspan3|table_header_scope_col_colspan4|
        table_header_scope_row_rowspan2|table_header_scope_row_rowspan3|table_header_scope_row_rowspan4">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    
</xsl:stylesheet>