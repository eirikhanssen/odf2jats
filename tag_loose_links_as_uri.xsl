<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="xml" indent="yes"></xsl:output>
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="text()[not(ancestor::uri)]">
        <xsl:variable name="markup_common_uris_output">
            <xsl:analyze-string select="." regex="(\c+://[^\s]+)">
                <xsl:matching-substring>
                    <uri>
                        <xsl:value-of select="regex-group(1)"/>
                    </uri>
                    <xsl:value-of select="regex-group(2)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:copy/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>

        <xsl:variable name="fix_trailing_punctiation_output">
            <xsl:apply-templates select="$markup_common_uris_output" mode="fix_trailing_punctuation"/>
        </xsl:variable>
        
        <xsl:sequence select="$fix_trailing_punctiation_output"/>
    </xsl:template>

    <xsl:template match="uri" mode="fix_trailing_punctuation">
            <xsl:choose>
                <xsl:when test="matches(. , '^.*?[,|.|;]$')">
                    <uri>
                        <xsl:copy-of select="@*"/>
                        <xsl:value-of select="replace(. , '(^.*?)(,|.|;)$' , '$1')"/>
                    </uri><xsl:value-of select="replace(. , '^.*?(,|.|;)$' , '$1')"/>
                </xsl:when>
                <xsl:otherwise>
                    <uri>
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates/>
                    </uri>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
