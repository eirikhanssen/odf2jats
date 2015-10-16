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

    <xsl:template match="p[position() &lt; 3][bold]">
        <xsl:choose>
            <xsl:when test="matches(bold[1], '^Abstract[:]\s*$')">
                <abstract>
                    <xsl:apply-templates mode="abstract_and_keywords"/>
                </abstract>
            </xsl:when>
            <xsl:when test="matches(bold[1], '^Keywords[:]?\s*$')">
                <keywords>
                    <xsl:apply-templates mode="abstract_and_keywords"/>
                </keywords>
            </xsl:when>
            <xsl:otherwise>
                <p>
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- if keywords are already marked up as <keywords>, delete <bold>Keywords</bold> -->

    <xsl:template match="keywords[bold]">
        <xsl:choose>
        <xsl:when test="matches(bold[1], '^Keywords[:]?\s*$')">
            <keywords>
                <xsl:apply-templates mode="abstract_and_keywords"/>
            </keywords>
        </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- if abstract is already marked up as <abstract>, delete <bold>Abstract</bold> -->
    
    <xsl:template match="abstract[bold]">
        <xsl:choose>
            <xsl:when test="matches(bold[1], '^Abstract[:]?\s*$')">
                <abstract>
                    <p><xsl:apply-templates mode="abstract_and_keywords"/></p>
                </abstract>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="abstract[not(p|bold)]">
        <abstract>
            <p><xsl:apply-templates mode="abstract_and_keywords"/></p>
        </abstract>
    </xsl:template>

    <!-- here is the template actually removing the <bold> elements in question -->

    <xsl:template match="bold[1]" mode="abstract_and_keywords">
        <xsl:choose>
            <xsl:when test="matches(. , '^Abstract[:]?\s*$|^Keywords[:]?\s*$')"></xsl:when>
            <xsl:otherwise>
                <bold>
                    <xsl:apply-templates/>
                </bold>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- remove colon and space from the beginning of the string inside abstract and keywords -->
    
    <xsl:template match="text()[1]" mode="abstract_and_keywords">
        <xsl:analyze-string select="." regex="^(:|\s)\s*">
            <xsl:matching-substring/>
            <xsl:non-matching-substring>
                <xsl:copy/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
</xsl:stylesheet>