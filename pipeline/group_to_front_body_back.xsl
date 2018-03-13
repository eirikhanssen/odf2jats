<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="xs"
    version="2.0">

<!-- TODO: later if we support multiple journals, 
the journal abbreviation should be given as a parameter, PP in this case, and this stylesheet should then 
fetch the file from the PP subfolder of ../xml-include -->

    <xsl:param name="journal-meta-common" select="doc('../xml-include/journal-meta-PP.xml')/journal-meta" as="element(journal-meta)"/>

    <xsl:param name="article-meta-common" select="doc('../xml-include/article-meta-common-PP.xml')/article-meta" as="element(article-meta)"/>

    <xsl:variable name="article-identifiers-string" select="string-join(//article-identifiers,'')"/>

    <xsl:template match="article">
        <xsl:variable name="article-identifiers">
            <xsl:for-each select="tokenize( replace(article-identifiers, '\t' , '|') , '\s*\|\s*' ) ">
                <xsl:choose>
                    <xsl:when test="matches(. , '^ISSN:\s*.*?$')">
                        <issn><xsl:value-of select="replace(. , '^ISSN:\s*(.*?)$', '$1' )"/></issn>
                    </xsl:when>
                    <xsl:when test="matches(. , '^Volume.*?$')">
                        <volume><xsl:value-of select="replace(. , '^Vol.+?(\d+).+$', '$1' )"/></volume>
                        <issue><xsl:value-of select="replace(. , '^.+?[nN]o.+?(\d+).+$', '$1' )"/></issue>
                        <elocation-id><xsl:value-of select="replace(. , '^.+?\s+(e.+)$', '$1' )"/></elocation-id>
                        <year><xsl:value-of select="replace(. , '^.+?[(]\s*(\d+).+?$', '$1' )"/></year>
                    </xsl:when>
                    <xsl:when test="matches(. , '^\s*https?:[/][/](dx\.)?doi\.org/.*?$')">
                        <self-uri><xsl:value-of select="."/></self-uri>
                        <doi><xsl:value-of select="replace(. , 'https://doi\.org/(.*?)$' , '$1')"/></doi>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <!-- xml:lang should not be hard-coded, but read from inside the input document -->
        <article article-type="research-article" dtd-version="1.1">
            <xsl:attribute name="xsi:noNamespaceSchemaLocation" select="'JATS-journalpublishing1-mathml3.xsd'"/>
            <front>
                <xsl:apply-templates select="$journal-meta-common"/>
                <article-meta>
<!--                    <xsl:comment>$article-identifiers-string: <xsl:value-of select="$article-identifiers-string"/></xsl:comment>-->
                    <xsl:element name="article-id">
                        <xsl:attribute name="pub-id-type">doi</xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$article-identifiers/doi">
                            	<xsl:value-of select="replace($article-identifiers/doi, '^\s*https?:[/][/](dx\.)?doi\.org/(.*?)$','$2')"/>
                            </xsl:when>
                            <xsl:otherwise><xsl:text>___</xsl:text></xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                    <xsl:apply-templates select="$article-meta-common/article-categories"/>
                    <title-group>
                        <xsl:apply-templates select="article-title"/>
                    </title-group>
                    <xsl:apply-templates select="authors"/>
                    <pub-date publication-format="electronic" date-type="pub">
                        
                        <xsl:choose>
                            <xsl:when test="date[@date-type='pub']">
                                <xsl:apply-templates select="date[@date-type='pub']/*"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <date date-type="published">
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
                                </date>
                            </xsl:otherwise>
                        </xsl:choose>
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
                    <elocation-id><xsl:value-of select="$article-identifiers/elocation-id"/></elocation-id>
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
                                	<xsl:value-of select="replace($article-identifiers/self-uri, '^\s*https?:[/][/](dx\.)?doi\.org/(.*?)$','https://doi.org/$2')"/>
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
	<!-- sometimes an extra comma before the 'and' between the two last authors creates a problem (empty sequence). Remove this comma here in the $authors_fix variable. -->
    	<xsl:variable name="authors_fix" select="replace(.,'\s*,\s* (and | &amp;)\s*',' and ')"/>
        <!-- these two variables are used when attaching the contact address to the author to be contacted -->
        <xsl:variable name="contact-info" select="/article/contact-info" as="element(contact-info)*"/>
        <xsl:variable name="contact-address">
                <xsl:for-each select="$contact-info">
                    <xsl:if test="matches( . , '^\s*[cC]ontact:')">
                    	<xsl:variable name="contactPersonString" select="replace( . , '^\s*[cC]ontact:\s*([^,]+),.*?$' , '$1')"/>
                    	<xsl:variable name="addressString" select="replace( . , '^\s*[cC]ontact:\s*[^,]+,\s*(.*?)$' , '$1')"/>
                        <contact_person><xsl:value-of select="$contactPersonString"/></contact_person>
                        <address_string><xsl:value-of select="$addressString"/></address_string>
                    </xsl:if>
                </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="author-group" as="element(contrib-group)">
            <contrib-group>
                <xsl:for-each select="tokenize( $authors_fix , ',|\sand\s|&amp;')">
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
                        <!-- add contact address if it matches the author (surname and given-names are present) -->                        
                        <xsl:choose>
                            <xsl:when test="$contact-address/contact_person and $contact-address/address_string">
                                <xsl:if test="
                                    matches($contact-address/contact_person , $current_name/surname) and 
                                    matches($contact-address/contact_person , $current_name/given-names)">
                                    <xsl:comment>Fixme! Properly tag &lt;adress>...&lt;/adress>:</xsl:comment>
                                    <xsl:comment>institution|addr-line|city|country|phone|postal-code|state|email|ext-link|uri</xsl:comment>
                                    <address>
                                        <xsl:analyze-string select="$contact-address/address_string" regex="\s*,\s*">
                                            <xsl:matching-substring/>
                                            <xsl:non-matching-substring>
                                                <xsl:variable name="current-line"><xsl:copy/></xsl:variable>
                                                <xsl:choose>
                                                    <xsl:when test="matches($current-line , '^[\c\d._%+-]+@[\c\d.-]+\.\c\c+$')">
                                                        <email><xsl:value-of select="$current-line"/></email>
                                                    </xsl:when>
                                                    <xsl:otherwise><addr-line><xsl:value-of select="$current-line"/></addr-line></xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:non-matching-substring>
                                        </xsl:analyze-string>
                                    </address>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
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