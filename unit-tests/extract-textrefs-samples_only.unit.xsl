<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xs xlink" version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="body">
        <samples>
            <xsl:apply-templates/>
        </samples>
    </xsl:template>

    <xsl:template match="text()[ancestor::body]">
        <xsl:analyze-string select="." regex="([^)]*?\(\d{{4}}\))">
            <xsl:matching-substring>
                    <sample><xsl:value-of select="regex-group(1)"/></sample>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:analyze-string select="." regex="(\([^()]*?\))">
                    <xsl:matching-substring>
                        <xsl:choose>
                            <xsl:when test="matches(regex-group(1), '\d{4}')">
                                    <sample><xsl:value-of select="regex-group(1)"/></sample>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring/>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template match="text()[not(ancestor::body)]"/>

</xsl:stylesheet>
