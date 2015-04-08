<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:o2j="https://github.com/eirikhanssen/odf2jats" exclude-result-prefixes="xs xlink o2j">

    <xsl:output method="xml" indent="yes"/>

    <xsl:function name="o2j:isAssumedToBeReference" as="xs:boolean">
        <xsl:param name="str" as="xs:string"/>
        <xsl:variable name="hasFourDigitsGroup" select="matches($str , '\d{4}')" as="xs:boolean"/>
        <xsl:variable name="hasLetters" select="matches($str , '\c+')" as="xs:boolean"/>
        <xsl:variable name="hasDigitRange" select="matches($str , '\d+\s*(-|–|—|\s)+\s*\d+')"/>
        <xsl:choose>
            <xsl:when test="$hasFourDigitsGroup eq false()">
                <!-- All in-text references have 4 digits in a row to refer to a year -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="$hasDigitRange eq true()">
                <!-- a digit-range in parens should not be considered a reference -->
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- if the two first tests failed, then it is probably a reference in the parens -->
                <xsl:value-of select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:variable name="parsedRefs">
        <xsl:apply-templates mode="reftextparser"/>
    </xsl:variable>

    <xsl:template match="test" mode="reftextparser">
        <test>
            <xsl:attribute name="tID">
                <xsl:number/>
            </xsl:attribute>
            <!-- test against unit test to see if generated result is same as target -->
            <xsl:sequence select="sample, target"/>
            <result>
                <xsl:apply-templates select="sample" mode="reftextparser"/>
            </result>
        </test>
    </xsl:template>

    <!--
        This template is a micro-pipeline, where parens that are identified to contain citation(s)
        are processed in several passes/phases using different modes.

        Each pass is stored as a temporary document in a variable that is used in the next pass/phase.

        The passes introduce temporary markup to be able to dissect the citation(s) within the parens
        and autogenerate or semi-autogenerate the rid of xref elements.

        Finally, the temporary markup is removed and cleaned up, ensuring that the xref-tagged citations 
        within parens are properly separated with commas, space and semicolons.
    -->

    <xsl:template match="element()[not(ancestor::ref-list)]/text()" mode="reftextparser">
        <xsl:analyze-string select="." regex="\(([^()]+)\)">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="o2j:isAssumedToBeReference(regex-group(1)) eq true()">
                        <!-- process the citation -->
                        <xsl:variable name="parensWithRefs">
                            <xsl:text>(</xsl:text>
                            <refs>
                                <xsl:value-of select="regex-group(1)"/>
                            </refs>
                            <xsl:text>)</xsl:text>
                        </xsl:variable>

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

                        <!-- <xsl:sequence select="$parensWithRefs"/> -->
                        <!-- <xsl:sequence select="$parensWithRefsGrouped"/> -->
                        <!-- <xsl:sequence select="$xrefsWithRidIfWhenLettersNotPresent"></xsl:sequence> -->
                        <xsl:sequence select="$xrefsInAuthorsGroupCleanup"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- the parens is not identified as a citation, just copy over unchanged -->
                        <xsl:copy/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:copy/>
            </xsl:non-matching-substring>
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
            <xsl:variable name="caps" select="replace(preceding-sibling::xref[@rid]/@rid , '\P{Lu}' ,'')"/>
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
                    <xsl:attribute name="rid" select="concat($caps , '    ' , $year)"/>
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

    <xsl:template match="/element()[1]">
        <xsl:element name="{name(.)}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="reftextparser"/>
        </xsl:element>
    </xsl:template>

    <!-- Default template for all modes-  do an identity transform and copy over the node unchanged -->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
