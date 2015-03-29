<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">

    <!-- Group body contents -->

    <xsl:template match="body">
            <body>
                <xsl:for-each-group select="element()" group-starting-with="h1">
                            <section lvl="1">
                                <xsl:for-each-group select="current-group()" group-starting-with="h2">
                                    <xsl:choose>
                                        <xsl:when test="current-group()[self::h2]">
                                            <section lvl="2">
                                                <xsl:for-each-group select="current-group()" group-starting-with="h3">
                                                    <xsl:choose>
                                                        <xsl:when test="current-group()[self::h3]">
                                                            <section lvl="3">
                                                                <xsl:apply-templates select="current-group()"/>
                                                            </section>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:apply-templates select="current-group()"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:for-each-group>
                                            </section>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:apply-templates select="current-group()"/>
                                        </xsl:otherwise>
                                    </xsl:choose>    
                                </xsl:for-each-group>
                            </section>                            
                </xsl:for-each-group>
            </body>
    </xsl:template>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>