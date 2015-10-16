<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:o2j="https://github.com/eirikhanssen/odf2jats"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="xs o2j">

    <xsl:output method="xml" indent="yes"/>

    <xsl:function name="o2j:isAssumedToBeUntaggedReference" as="xs:boolean">
        <xsl:param name="str" as="xs:string"/>
        <xsl:variable name="hasFourDigitsGroup" select="matches($str , '\d{4}')" as="xs:boolean"/>
        <xsl:variable name="hasLetters" select="matches($str , '\c+')" as="xs:boolean"/>
        <xsl:variable name="hasDigitRange" select="matches($str , '\d+\s*(-|–|—|\s)+\s*\d+')"/>
        <xsl:variable name="onlyOneFourDigitsGroup" select="matches($str , '^\D*?\d{4}\D*?$')" as="xs:boolean"></xsl:variable>
        <xsl:variable name="currentYear" select="year-from-date(current-date())" as="xs:integer"/>
        <xsl:variable name="numberInParens" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$onlyOneFourDigitsGroup eq true()">
                    <xsl:variable name="digitsOnly" as="xs:string">
                        <xsl:analyze-string select="$str" regex="\D">
                            <xsl:matching-substring/>
                            <xsl:non-matching-substring>
                                <xsl:copy/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                    <xsl:value-of select="xs:integer($digitsOnly)"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="xs:integer(0)"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$hasFourDigitsGroup eq false()">
                <!-- All in-text references have 4 digits in a row to refer to a year -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="$hasDigitRange eq true()">
                <!-- a digit-range in parens should not be considered a reference -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="matches($str, '^[nN]\s*=\s*\d+$')">
                <xsl:message>
                    <xsl:text>The parens: «(</xsl:text>
                    <xsl:value-of select="$str"/>
                    <xsl:text>)» was not recognized as a citation (probably numeric data). Please check manually.</xsl:text>
                </xsl:message>
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="$onlyOneFourDigitsGroup eq true() and ($numberInParens &lt; ($currentYear - 100) or $numberInParens &gt; $currentYear + 1)">
                <xsl:message>
                    <xsl:text>The parens: «(</xsl:text>
                    <xsl:value-of select="$str"/>
                    <xsl:text>)» was not recognized as a citation (number out of bounds for year). Please check manually.</xsl:text>
                </xsl:message>
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- if all the other tests failed, then it is probably an untagged reference in the parens -->
                <xsl:value-of select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
        Store all refs with element-citation in a variable for comparing et al. type citations against 
        referencs in the ref-list 
    -->
    <xsl:variable name="element-citation-refs" select="/article/back/ref-list/ref[element-citation]"/>

    <!--
        This template is a micro-pipeline, where parens that are identified to contain citation(s)
        are processed in several passes/phases using different modes.

        Each pass is stored as a temporary document in a variable that is used in the next pass/phase.

        The passes introduce temporary markup to be able to dissect the citation(s) within the parens
        and autogenerate or semi-autogenerate the rid of xref elements.

        Finally, the temporary markup is removed and cleaned up, ensuring that the xref-tagged citations 
        within parens are properly separated with commas, space and semicolons.
    -->

    <!-- don't process text in the reference list or already tagged references -->
    <xsl:template match="element()[not(ancestor::ref-list)]/text()[not(ancestor::xref)]">
        <xsl:analyze-string select="." regex="\(([^()]+)\)">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="o2j:isAssumedToBeUntaggedReference(regex-group(1)) eq true()">

                        <!-- process the citation -->
                        <xsl:variable name="parensWithRefs">
                            <xsl:text>(</xsl:text><refs><xsl:value-of select="regex-group(1)"/></refs><xsl:text>)</xsl:text></xsl:variable>

                        <xsl:variable name="parensWithRefsGrouped">
                            <xsl:apply-templates select="$parensWithRefs"
                                mode="groupRefsInParensByAuthors"/>
                        </xsl:variable>

                        <xsl:variable name="refsBySameAuthorsTokenized">
                            <xsl:apply-templates select="$parensWithRefsGrouped"
                                mode="tokenizeRefsBySameAuthors"/>
                        </xsl:variable>

                        <xsl:variable name="xrefsWithRidIfLettersPresent">
                            <xsl:apply-templates select="$refsBySameAuthorsTokenized"
                                mode="genIdIfAuthorsAndYear"/>
                        </xsl:variable>

                        <xsl:variable name="xrefsWithRidIfWhenLettersNotPresent">
                            <xsl:apply-templates select="$xrefsWithRidIfLettersPresent"
                                mode="genIdWhenCapsLetterNotPresent"/>
                        </xsl:variable>

                        <xsl:variable name="xrefsInAuthorsGroupCleanup">
                            <xsl:apply-templates select="$xrefsWithRidIfWhenLettersNotPresent"
                                mode="cleanupXrefsInAuthorsGroup"/>
                        </xsl:variable>

                        <xsl:sequence select="$xrefsInAuthorsGroupCleanup"/>
                    </xsl:when>
                    <!-- 
                        When the parens is not identified as a citation, just copy it over unchanged. 
                        
                        Strangely the empty <xsl:text/> are needed here to prevent insertion of extra space
                        around parens that are identified as not containing text-refs.
                    -->
                    <xsl:otherwise><xsl:text/><xsl:copy/><xsl:text/></xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring><xsl:text/><xsl:copy/><xsl:text/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template match="refs" mode="cleanupXrefsInAuthorsGroup">
        <xsl:apply-templates mode="cleanupXrefsInAuthorsGroup"/>
    </xsl:template>

    <xsl:template match="refsBySameAuthors" mode="cleanupXrefsInAuthorsGroup">
        <xsl:apply-templates mode="cleanupXrefsInAuthorsGroup"/>
        <xsl:if test="position() &lt; last()"><xsl:text>; </xsl:text></xsl:if>
    </xsl:template>

    <xsl:template match="refsBySameAuthors/xref" mode="cleanupXrefsInAuthorsGroup">
        <xsl:element name="xref">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="cleanupXrefsInAuthorsGroup"/>
        </xsl:element>
        <xsl:if test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:if>
    </xsl:template>

    <xsl:template match="refs" mode="genIdWhenCapsLetterNotPresent">
        <refs>
            <xsl:apply-templates mode="genIdWhenCapsLetterNotPresent"/>
        </refs>
    </xsl:template>

    <xsl:template match="refsBySameAuthors" mode="genIdWhenCapsLetterNotPresent">
        <refsBySameAuthors>
            <xsl:apply-templates mode="genIdWhenCapsLetterNotPresent"/>
        </refsBySameAuthors>
    </xsl:template>

    <xsl:template match="refsBySameAuthors/xref" mode="genIdWhenCapsLetterNotPresent">
        <xref ref-type="bibr">
            <xsl:variable name="caps" select="replace(preceding-sibling::xref[1][@rid]/@rid , '\P{Lu}' ,'')"/>
            <xsl:variable name="year" select="replace( . , '.*(\d{4}\c*)', '$1')"/>
            <xsl:choose>
                <xsl:when test="not(@rid) and $caps =''">
                    <xsl:attribute name="rid" select="concat('    ' , $year)"/>
                </xsl:when>
                <xsl:when test="not(@rid)">
                    <xsl:attribute name="rid" select="concat($caps, $year)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="@rid"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates mode="genIdIfAuthorsAndYear"/>
        </xref>
    </xsl:template>

    <xsl:template match="refs" mode="genIdIfAuthorsAndYear">
        <refs>
            <xsl:apply-templates mode="genIdIfAuthorsAndYear"/>
        </refs>
    </xsl:template>

    <xsl:template match="refsBySameAuthors" mode="genIdIfAuthorsAndYear">
        <refsBySameAuthors>
            <xsl:apply-templates mode="genIdIfAuthorsAndYear"/>
        </refsBySameAuthors>
    </xsl:template>

    <xsl:template match="xref" mode="genIdIfAuthorsAndYear">
        <xref ref-type="bibr">
            <xsl:variable name="caps" select="replace( . , '\P{Lu}' , '')"/>
            <xsl:variable name="year" select="replace( . , '.*(\d{4}\c*)', '$1')"/>
            <xsl:choose>
                <xsl:when test="matches( . ,'\p{Lu}') and matches( . , 'et al\.')">
                    <xsl:variable name="first_author_surname_in_citation" select="replace(. , '^\s*(\c*?)[,]?\s*?et\s+al.*?$', '$1')"/>
                    <xsl:choose>
                        <!-- 
                            If there is one and only one ref in the ref-list where the first author's surname and the year matches the 
                            surname and year in an et al. citation, then copy the id from that ref in the ref-list to the rid-attribute 
                            in this xref element. 
                        -->
                        <xsl:when test="count($element-citation-refs[(matches(element-citation/person-group[1]/name[1]/surname , $first_author_surname_in_citation)) and element-citation/year = $year]) = 1">
                            <xsl:attribute name="rid" select="$element-citation-refs[(matches(element-citation/person-group[1]/name[1]/surname , $first_author_surname_in_citation)) and element-citation/year = $year]/@id"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="rid" select="concat($caps , '    ' , $year)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="matches( . ,'\p{Lu}')">
                    <xsl:attribute name="rid" select="concat($caps, $year)"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates mode="genIdIfAuthorsAndYear"/>
        </xref>
    </xsl:template>

    <xsl:template match="refs" mode="tokenizeRefsBySameAuthors">
        <refs>
            <xsl:apply-templates mode="tokenizeRefsBySameAuthors"/>
        </refs>
    </xsl:template>

    <xsl:template match="refsBySameAuthors" mode="tokenizeRefsBySameAuthors">
        <refsBySameAuthors>
            <xsl:variable name="sameAuthorsRefStringTokenized">
                <xsl:value-of select="replace(. , '(\d{4}\c*\s*),' , '$1|')"/>
            </xsl:variable>
            <xsl:for-each select="tokenize($sameAuthorsRefStringTokenized , '[|]')">
                <xref>
                    <xsl:value-of select="normalize-space(.)"/>
                </xref>
            </xsl:for-each>
        </refsBySameAuthors>
    </xsl:template>

    <xsl:template match="refs" mode="groupRefsInParensByAuthors">
        <refs>
            <xsl:for-each select="tokenize( . , ';')">
                <refsBySameAuthors>
                    <xsl:value-of select="normalize-space(.)"/>
                </refsBySameAuthors>
            </xsl:for-each>
        </refs>
    </xsl:template>

    <xsl:template match="/element()">
        <xsl:element name="{name(.)}">
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="document('')/*/namespace::*[name()='xlink']"/>
            <xsl:copy-of select="document('')/*/namespace::*[name()='xsi']"/>
            <xsl:copy-of select="document('')/*/namespace::*[name()='mml']"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- Default template for all modes-  do an identity transform and copy over the node unchanged -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
