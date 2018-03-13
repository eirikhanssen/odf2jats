<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:o2j="https://github.com/eirikhanssen/odf2jats"
    exclude-result-prefixes="xs o2j"
    version="2.0">
    <xsl:import href="odf2jats-functions.xsl"/>
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="text()" priority="2">
        <xsl:variable name="remove_comma_after_et_al" as="xs:string">
            <xsl:variable name="remove_comma_after_et_al_sequence" as="xs:string*">
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
            </xsl:variable>
            <xsl:value-of select="string-join($remove_comma_after_et_al_sequence,'')"/>
        </xsl:variable>
        
        <!--<xsl:variable name="ellipsis">
            <xsl:value-of select="o2j:replace( $remove_comma_after_et_al , '\s*\.\s*\.\s*\.\s*&amp;\s*' , ' … ')"/>
        </xsl:variable>-->
        
        <xsl:variable name="ellipsis" as="xs:string">
            <xsl:variable name="ellipsis_result_sequence" as="xs:string*">
                <xsl:analyze-string select="$remove_comma_after_et_al" regex="([^ ]*?)?\s*\.\s*\.\s*\.\s*&amp;?\s*?(.{{3,9}})?">
                    <xsl:matching-substring>
                        <xsl:message>
                            <xsl:text>Fix ellipsis: replaced «</xsl:text>
                            <xsl:value-of select="regex-group(0)"/>
                            <xsl:text>» with «</xsl:text>
                            <xsl:value-of select="concat(regex-group(1) , ' … ' , regex-group(2))"/>
                            <xsl:text>»</xsl:text>
                        </xsl:message>
                        <xsl:value-of select="concat(regex-group(1) , ' … ' , regex-group(2))"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:copy/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:value-of select="string-join($ellipsis_result_sequence,'')"/>
        </xsl:variable>
        
        <xsl:value-of select="$ellipsis"/>
        
    </xsl:template>

    <!-- Default template for all modes-  do an identity transform and copy over the node unchanged -->
    <xsl:template match="node()|@*" priority="1">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>