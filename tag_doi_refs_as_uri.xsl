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
            <xsl:variable name="doi_tagged_as_uri">
                <xsl:analyze-string select="." regex="(doi\s*:\s*)([^\s]+)">
                    <xsl:matching-substring>
                        <uri>http://dx.doi.org/<xsl:value-of select="regex-group(2)"/></uri>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:copy/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
                </xsl:variable>
        <xsl:apply-templates select="$doi_tagged_as_uri" mode="remove_doi_marker_before_doi_link_uri"/>
    </xsl:template>

</xsl:stylesheet>