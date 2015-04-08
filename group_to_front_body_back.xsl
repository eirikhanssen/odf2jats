<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:param name="journal-meta-common" select="doc('journal-meta-PP.xml')/journal-meta" as="element(journal-meta)"/>

    <xsl:param name="article-meta-common" select="doc('article-meta-common-PP.xml')/article-meta" as="element(article-meta)"/>

    <xsl:template match="article">
        <article article-type="research-article">
            <front>
                <xsl:apply-templates select="$journal-meta-common"/>
                <article-meta>
                    <xsl:element name="article-id">
                        <xsl:attribute name="pub-id-type">doi</xsl:attribute>
                        <xsl:text>____</xsl:text>
                    </xsl:element>
                    <xsl:apply-templates select="$article-meta-common/article-categories"/>
                    <title-group>
                        <article-title>
                            <xsl:apply-templates select="article-title"/>
                        </article-title>
                    </title-group>
                        <xsl:apply-templates select="authors"/>
                    <pub-date pub-type="pub">
                        <day>____</day>
                        <month>____</month>
                        <year>____</year>
                    </pub-date>
                    <volume>____</volume>
                    <issue>____</issue>
                    <fpage>____</fpage>
                    <lpage>____</lpage>
                    <history>
                        <date date-type="received">
                            <day>____</day>
                            <month>____</month>
                            <year>____</year>
                        </date>
                        <date date-type="accepted">
                            <day>____</day>
                            <month>____</month>
                            <year>____</year>
                        </date>
                    </history>
                    <xsl:apply-templates select="$article-meta-common/permissions"/>
                    <self-uri xlink:href="____">____</self-uri>
                    <xsl:apply-templates select="abstract"/>
                    <kwd-group kwd-group-type="author-generated">
                        <xsl:for-each select="tokenize(keywords, ',')">
                            <kwd><xsl:value-of select="replace(normalize-space(.), '[.]$', '')"/></kwd>
                        </xsl:for-each>
                    </kwd-group>
                </article-meta>
            </front>
            <body>
                <xsl:apply-templates mode="body"/>
            </body>
            <back>
                <!-- fn-group if there is atleast one footnote -->
                <!-- table-wrap can have it's own footnote-group that should not be here?
                     WIP: check JATS -->
                <xsl:if test="count(//fn) gt 0">
                    <fn-group>
                        <xsl:apply-templates select="//fn"/>
                    </fn-group>
                </xsl:if>
                <ref-list>
                    <xsl:apply-templates select="ref"/>                    
                </ref-list>
            </back>
        </article>
    </xsl:template>

    <xsl:template match="authors">
        <xsl:variable name="author-group" as="element(contrib-group)">
            <contrib-group>
                <xsl:for-each select="tokenize(., ',')">
                    <contrib contrib-type="author">
                        <name>
                            <xsl:analyze-string select="normalize-space(.)" regex="\c+$">
                                <xsl:matching-substring>
                                    <surname><xsl:value-of select="normalize-space(.)"/></surname>
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <given-names><xsl:value-of select="normalize-space(.)"/></given-names>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </name>
                        <xsl:variable name="aff_rid" select="concat(replace(normalize-space(.) , '^(.).+' , '$1') , '_' , replace( . , '.+\s' , ''))"/>
                        <xsl:element name="xref">
                            <xsl:attribute name="ref-type">aff</xsl:attribute>
                            <xsl:attribute name="rid"><xsl:value-of select="$aff_rid"/></xsl:attribute>
                        </xsl:element>
                    </contrib>    
                </xsl:for-each>
            </contrib-group>
        </xsl:variable>

        <xsl:variable name="affs">
            <xsl:for-each select="$author-group/contrib/xref[@ref-type='aff']">
                <xsl:element name="aff">
                    <xsl:attribute name="id" select="@rid"/>
                    <xsl:text>____</xsl:text>
                </xsl:element>
            </xsl:for-each>
        </xsl:variable>

        <xsl:sequence select="$author-group, $affs"/>

    </xsl:template>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- These should not be applied to the body as they will be put in front or back -->
    <!-- since fn is listed here, it should not appear in the body, yet it does! -->
    <!-- If I can't prevent it from appearing in the body, I suppose I have to delete it with XProc -->
    <xsl:template match="fn|abstract|keywords|authors|article-title|ref" mode="body"/>

    <xsl:template match="node()|@*" mode="body">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>