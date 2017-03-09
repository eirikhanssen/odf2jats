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

    <!-- 
        If abstract and keywords are marked up as such, it is easier, but if not, 
        this first template rule will take care of that
        
        If the two first p-elements have child element <bold> that has just the text 
        "Abstract" or "Keywords" then delete that child <bold> element, 
        rename this element to abstract or keywords,
        
        and remove colon and space from the beginning of the text() node following
    -->

    <!-- if a td has a table_header child, then it should be a th-element -->
    
    <xsl:template match="unknown_style[parent::list-item]">
        <p><xsl:apply-templates/></p>
    </xsl:template>
</xsl:stylesheet>