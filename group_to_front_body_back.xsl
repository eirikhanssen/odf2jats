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
        <xsl:variable name="article-identifiers">
            <xsl:for-each select="tokenize( replace(article-identifiers, '\t' , '|') , '\s*\|\s*' ) ">
                <xsl:choose>
                    <xsl:when test="matches(. , '^ISSN:\s*.*?$')">
                        <issn><xsl:value-of select="replace(. , '^ISSN:\s*(.*?)$', '$1' )"/></issn>
                    </xsl:when>
                    <xsl:when test="matches(. , '^Volume.*?\d+\D*?\d+\D*?\(\d{4}\)$')">
                        <volume><xsl:value-of select="replace(. , '^Volume.*?(\d+)\D*?\d+\D*?\(\d{4}\)$', '$1' )"/></volume>
                        <issue><xsl:value-of select="replace(. , '^Volume.*?\d+\D*?(\d+)\D*?\(\d{4}\)$', '$1' )"/></issue>
                        <year><xsl:value-of select="replace(. , '^Volume.*?\d+\D*?\d+\D*?\((\d{4})\)$', '$1' )"/></year>
                    </xsl:when>
                    <xsl:when test="matches(. , '^\s*http://(dx\.)?doi\.org/.*?$')">
                        <self-uri><xsl:value-of select="."/></self-uri>
                        <doi><xsl:value-of select="replace(. , 'http://dx\.doi\.org/(.*?)$' , '$1')"/></doi>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <article article-type="research-article">
            <xsl:attribute name="xsi:noNamespaceSchemaLocation">
                <xsl:text>../../jats/JATS-Publishing-1-1d3-MathML3-XSD/JATS-Publishing-1-1d3-MathML3-XSD/JATS-journalpublishing1-mathml3.xsd</xsl:text>
            </xsl:attribute>
            <front>
                <xsl:apply-templates select="$journal-meta-common"/>
                <article-meta>
                    <xsl:element name="article-id">
                        <xsl:attribute name="pub-id-type">doi</xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$article-identifiers/doi">
                                <xsl:value-of select="$article-identifiers/doi"/>
                            </xsl:when>
                            <xsl:otherwise><xsl:text>___</xsl:text></xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:apply-templates select="$article-meta-common/article-categories"/>
                    <title-group>
                        <xsl:apply-templates select="article-title"/>
                    </title-group>
                    <xsl:apply-templates select="authors"/>
                    <pub-date pub-type="pub">
                        <day>___</day>
                        <month>___</month>
                        <year>
                            <xsl:choose>
                                <xsl:when test="$article-identifiers/year">
                                    <xsl:value-of select="$article-identifiers/year"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>___</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </year>
                    </pub-date>
                    <volume>
                        <xsl:choose>
                            <xsl:when test="$article-identifiers/volume">
                                <xsl:value-of select="$article-identifiers/volume"/>
                            </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>___</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    </volume>
                    <issue>
                        <xsl:choose>
                            <xsl:when test="$article-identifiers/issue">
                                <xsl:value-of select="$article-identifiers/issue"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>___</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </issue>
                    <fpage>___</fpage>
                    <lpage>___</lpage>
                    <history>
                        <xsl:choose>
                            <xsl:when test="date[@date-type='received']">
                                <xsl:sequence select="date[@date-type='received']"></xsl:sequence>
                            </xsl:when>
                            <xsl:otherwise>
                                <date date-type="received">
                                    <day>___</day>
                                    <month>___</month>
                                    <year>___</year>
                                </date>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="date[@date-type='accepted']">
                                <xsl:sequence select="date[@date-type='accepted']"></xsl:sequence>
                            </xsl:when>
                            <xsl:otherwise>
                                <date date-type="accepted">
                                    <day>___</day>
                                    <month>___</month>
                                    <year>___</year>
                                </date>
                            </xsl:otherwise>
                        </xsl:choose>
                    </history>
                    <xsl:apply-templates select="$article-meta-common/permissions"/>
                    <xsl:element name="self-uri">
                        <xsl:variable name="hyperlink">
                            <xsl:choose>
                                <xsl:when test="$article-identifiers/self-uri">
                                    <xsl:value-of select="$article-identifiers/self-uri"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>___</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="$hyperlink"/>
                        </xsl:attribute>
                        <xsl:value-of select="$hyperlink"/>
                    </xsl:element>
                    <xsl:apply-templates select="abstract"/>
                    <kwd-group kwd-group-type="author-generated">
                        <!-- Remove the text "Keywords: " from the beginning of the keywords. -->
                        <xsl:for-each select="tokenize(replace(keywords, '^\s*Keywords:\s*' ,''), ',')">
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
                <xsl:if test="/article/ref[position() = last()]/following::node()">
                    <sec>
                        <title>Appendix</title>
                        <xsl:apply-templates mode="appendix"/>
                    </sec>
                </xsl:if>
            </back>
        </article>
    </xsl:template>

    <!-- Remove the text "Abstract: " from the beginning of the abstract. -->
    <xsl:template match="abstract/p[1]/text()[1]">
        <xsl:value-of select="replace(. , '^\s*Abstract:\s*' , '')"></xsl:value-of>
    </xsl:template>

    <xsl:template match="authors">
        <xsl:variable name="contact-info" select="/article/contact-info" as="element(contact-info)*"/>
        <xsl:variable name="author-group" as="element(contrib-group)">
            <contrib-group>
                <xsl:for-each select="tokenize( . , ',|\sand\s|&amp;')">
                    <xsl:variable name="current_name">
                        <xsl:analyze-string select="normalize-space(.)" regex="\c+$">
                            <xsl:matching-substring>
                                <surname><xsl:value-of select="normalize-space(.)"/></surname>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <given-names><xsl:value-of select="normalize-space(.)"/></given-names>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                    <contrib contrib-type="author">
                        <name>
                            <xsl:sequence select="$current_name/surname, $current_name/given-names"/>
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
                <xsl:variable name="currentAuthorSurname" select="../name/surname" as="xs:string"/>
                <xsl:variable name="currentAuthorGivenNames" select="../name/given-names" as="xs:string"/>
                <xsl:variable name="currentContactInfo">
                    <xsl:for-each select="$contact-info">
                        <xsl:if test="matches( . , $currentAuthorGivenNames) and matches( . , $currentAuthorSurname) and not(matches( . , '^\s*[Cc]ontact:'))">
                            <xsl:value-of select="replace( . , '^[^,]*?,\s*(.*?)$','$1')"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>

                <xsl:element name="aff">
                    <xsl:attribute name="id" select="@rid"/>
                    <xsl:choose>
                        <xsl:when test="not(empty($currentContactInfo) and $currentContactInfo != '')">
                            <xsl:value-of select="$currentContactInfo"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>___</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
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
    <xsl:template match="fn|abstract|keywords|authors|article-title|ref|date|article-identifiers|contact-info" mode="body"/>

    <xsl:template match="node()|@*" mode="body">
        <!-- if it has preceding::ref, then do nothing (don't copy the node to body) -->
        <!-- starting with ref-nodes in the reference list, all content should be placed in the back section -->
        <xsl:choose>
            <xsl:when test="preceding::ref"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="node()|@*"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="appendix">
        <!-- if it has preceding ref nodes, and it is not a ref node itself, then copy to the appendix -->
        <xsl:choose>
            <xsl:when test="preceding::ref and not(self::ref)">
                <xsl:copy>
                    <xsl:apply-templates select="node()|@*"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>