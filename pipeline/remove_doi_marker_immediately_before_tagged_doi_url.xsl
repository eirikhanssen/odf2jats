<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="xml" indent="yes"></xsl:output>
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <!-- If an uri element with a doi-url to http://dx.doi.org is preceded by the text 'doi: '
    then the text 'doi: ' is removed -->
    <xsl:template match="text()[matches(following-sibling::uri[1], '//(dx\.)?doi\.org')][matches(. , 'doi:\s*$')]">
        <xsl:analyze-string select="." regex="doi:\s*$">
            <xsl:matching-substring/>
            <xsl:non-matching-substring>
                <xsl:copy/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

</xsl:stylesheet>