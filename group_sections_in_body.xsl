<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <!-- Group body contents -->

    <xsl:template match="body">
        <body>
            <xsl:for-each-group select="*" group-starting-with="h1">
                <xsl:choose>
                    <xsl:when test="current-group()[self::h1]">
                        <xsl:comment> sec lvl 1 begin </xsl:comment><sec lvl="1">
                                <xsl:for-each-group select="current-group()" group-starting-with="h2">
                                    <xsl:choose>
                                        <xsl:when test="current-group()[self::h2]">
                                            <xsl:comment> sec lvl 2 begin </xsl:comment><sec lvl="2">
                                                    <xsl:for-each-group select="current-group()" group-starting-with="h3">
                                                        <xsl:choose>
                                                            <xsl:when test="current-group()[self::h3]">
                                                                <xsl:comment> sec lvl 3 begin </xsl:comment><sec lvl="3">
                                                                    <xsl:for-each-group select="current-group()" group-starting-with="h4">
                                                                        <xsl:choose>
                                                                            <xsl:when test="current-group()[self::h4]">
                                                                                <xsl:comment> sec lvl 4 begin </xsl:comment><sec lvl="4">
                                                                                    <xsl:for-each-group select="current-group()" group-starting-with="h5">
                                                                                        <xsl:choose>
                                                                                            <xsl:when test="current-group()[self::h5]">
                                                                                                <xsl:comment> sec lvl 5 begin </xsl:comment><sec lvl="5">
                                                                                                    <xsl:for-each-group select="current-group()" group-starting-with="h6">
                                                                                                        <xsl:choose>
                                                                                                            <xsl:when test="current-group()[self::h6]">
                                                                                                                <xsl:comment> sec lvl 6 begin </xsl:comment><sec lvl="6">
                                                                                                                    <xsl:for-each select="current-group()">
                                                                                                                        <xsl:copy-of select="."/>
                                                                                                                    </xsl:for-each>
                                                                                                                </sec><xsl:comment> sec lvl 6 end </xsl:comment>
                                                                                                            </xsl:when>
                                                                                                            <xsl:otherwise>
                                                                                                                <xsl:for-each select="current-group()">
                                                                                                                    <xsl:copy-of select="."/>
                                                                                                                </xsl:for-each>
                                                                                                            </xsl:otherwise>
                                                                                                        </xsl:choose>
                                                                                                    </xsl:for-each-group>
                                                                                                </sec><xsl:comment> sec lvl 5 end </xsl:comment>
                                                                                            </xsl:when>
                                                                                            <xsl:otherwise>
                                                                                                <xsl:for-each select="current-group()">
                                                                                                    <xsl:copy-of select="."/>
                                                                                                </xsl:for-each>
                                                                                            </xsl:otherwise>
                                                                                        </xsl:choose>
                                                                                    </xsl:for-each-group>
                                                                                </sec><xsl:comment> sec lvl 4 end </xsl:comment>
                                                                            </xsl:when>
                                                                            <xsl:otherwise>
                                                                                <xsl:for-each select="current-group()">
                                                                                    <xsl:copy-of select="."/>
                                                                                </xsl:for-each>
                                                                            </xsl:otherwise>
                                                                        </xsl:choose>
                                                                    </xsl:for-each-group>
                                                                </sec><xsl:comment> sec lvl 3 end </xsl:comment>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:for-each select="current-group()">
                                                                    <xsl:copy-of select="."/>
                                                                </xsl:for-each>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:for-each-group>
                                            </sec><xsl:comment> sec lvl 2 end </xsl:comment>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:for-each select="current-group()">
                                                <xsl:copy-of select="."/>
                                            </xsl:for-each>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each-group>
                        </sec><xsl:comment> sec lvl 1 end </xsl:comment>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="current-group()">
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </body>
    </xsl:template>
    
    <!-- Identity transform template -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
