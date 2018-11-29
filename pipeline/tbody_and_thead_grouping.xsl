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

    <!-- if the first table row has only th and no td, it belongs in thead, otherwise it belongs in tbody -->
    
    <xsl:template match="table">
        <table>
            <xsl:copy-of select="@*"></xsl:copy-of>
            <xsl:choose>
                <xsl:when test="not(tr[1]/td)">
                    <xsl:if test="tr[1]/th">
                        <thead>
                            <xsl:apply-templates select="tr[position() = 1]"/>
                        </thead>
                        <tbody>
                            <xsl:apply-templates select="tr[position() &gt; 1]"></xsl:apply-templates>
                        </tbody>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <tbody>
                        <xsl:apply-templates select="tr"/>
                    </tbody>
                </xsl:otherwise>
            </xsl:choose>
        </table>
    </xsl:template>
    
</xsl:stylesheet>