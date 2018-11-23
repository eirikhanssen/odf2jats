<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:o2j="https://github.com/eirikhanssen/odf2jats"
    exclude-result-prefixes="xs o2j"
    version="2.0">
    
    <xsl:function name="o2j:monthToInt" as="xs:integer">
        <xsl:param name="monthstring" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="matches($monthstring , '[Jj]an')">1</xsl:when>
            <xsl:when test="matches($monthstring , '[Ff]eb')">2</xsl:when>
            <xsl:when test="matches($monthstring , '[Mm]ar')">3</xsl:when>
            <xsl:when test="matches($monthstring , '[Aa]pr')">4</xsl:when>
            <xsl:when test="matches($monthstring , '[Mm]a[iy]')">5</xsl:when>
            <xsl:when test="matches($monthstring , '[Jj]un')">6</xsl:when>
            <xsl:when test="matches($monthstring , '[Jj]ul')">7</xsl:when>
            <xsl:when test="matches($monthstring , '[Aa]ug')">8</xsl:when>
            <xsl:when test="matches($monthstring , '[Ss]ep')">9</xsl:when>
            <xsl:when test="matches($monthstring , '[Oo][ck]t')">10</xsl:when>
            <xsl:when test="matches($monthstring , '[Nn]ov')">11</xsl:when>
            <xsl:when test="matches($monthstring , '[Dd]e[cs]')">12</xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- is this really needed?? -->
    
    <xsl:function name="o2j:replace" as="xs:string">
        <xsl:param name="original_string" as="xs:string"/>
        <xsl:param name="replace_regex" as="xs:string"/>
        <xsl:param name="replacement_string" as="xs:string"/>
        <xsl:variable name="result" as="xs:string*">
            <xsl:analyze-string select="$original_string" regex="{$replace_regex}" >
                <xsl:matching-substring>
                    <xsl:message>
                        <xsl:text>replaced «</xsl:text>
                        <xsl:value-of select="regex-group(0)"/>
                        <xsl:text>» with «</xsl:text>
                        <xsl:value-of select="$replacement_string"/>
                        <xsl:text>»</xsl:text>
                    </xsl:message>
                    <xsl:value-of select="$replacement_string"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:copy/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of select="string-join($result,'')"/>
    </xsl:function>
    
    <xsl:function name="o2j:trimseq" as="xs:string?">
        <!-- take a sequence of nodes, join the string value, trim whitespace and return the resulting string -->
        <xsl:param name="input_seq"/>
        <xsl:variable name="input_string" select='string-join($input_seq, "")'/>
        <xsl:value-of select="o2j:trimstr($input_string)"/>
    </xsl:function>
    
    <xsl:function name="o2j:trimstr" as="xs:string?">
        <!-- take a text input string, trim whitespace and return the resulting string -->
        <xsl:param name="input_string" as="xs:string"/>
        <xsl:variable name="trimmed_edges" select="replace($input_string, '^\s*(.+?)\s*$','$1')"/>
        <xsl:variable name="trimmed_contents" select="replace($trimmed_edges, '[ ]+',' ')"/>
        <xsl:value-of select="$trimmed_contents"/>
    </xsl:function>
    
    <!-- reftext parser functions -->
    
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
    
    <!-- reflist parser functions -->
    
    
    
    <xsl:function name="o2j:replaceAmpInAuthorstring" as="xs:string">
        <xsl:param name="originalString" as="xs:string"/>
        <!-- replace the &amp; (preceeded by comma and optional space) before the last author in authorstring with comma -->
        <!-- then different authors in the authorstring will be separated by (last initial) (dot) (comma) -->
        <xsl:value-of select="replace($originalString, ',*?\s*&amp;' , ',')"/>
    </xsl:function>
  
    <xsl:function name="o2j:normalizeInitialsInAuthorstring" as="xs:string">
        <xsl:param name="originalString" as="xs:string"/>
        <xsl:value-of
            select="
            normalize-space(
            replace(
            replace(
            replace(
            $originalString , '(\s\c)\s' , '$1. ') ,
            '(\c{3,})(\s\c)' , '$1,$2') ,
            '(\c{3,},\s\c),' , '$1.,')
            )"/>
        <!-- (inner replace) - Correct missing dot after initial: Molander, A => Molander, A. -->
        <!-- (middle replace) - Correct missing comma after surname: Lundberg U. => Lundberg, U. -->
        <!-- (outer replace) - Correct missing dot after initial: Lund, A, = > Lund, A., -->
        <!-- (outer replace) - Correct missing dot after initial: Krantz, J, => Krantz, J., -->
    </xsl:function>
    
    <xsl:function name="o2j:prepareTokens" as="xs:string">
        <xsl:param name="originalString" as="xs:string"/>
        <!-- replace comma and whitespace between two authors in authorstring with vertical bar -->
        <xsl:value-of select="replace($originalString, '(\c\.),\s*?' , '$1|')"/>
    </xsl:function>
    
    <xsl:function name="o2j:tokenizeAuthors" as="xs:string">
        <xsl:param name="originalString" as="xs:string"/>
        <!-- strip (Ed.). or (Eds.). from authorstring if it is before year in parens -->
        <xsl:variable name="originalStringEdsStripped">
            <xsl:analyze-string select="$originalString" regex="\s*\(Ed[s]?\.?\)\.?\s*">
                <xsl:matching-substring>
                    <xsl:text> </xsl:text><xsl:value-of select="regex-group(1)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:copy/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:value-of select="o2j:prepareTokens(o2j:replaceAmpInAuthorstring(o2j:normalizeInitialsInAuthorstring($originalStringEdsStripped)))"/>
    </xsl:function>
    
    <xsl:function name="o2j:getSurnameFromTokenizedAuthor" as="xs:string">
        <xsl:param name="originalString" as="xs:string"/>
        <xsl:value-of select="replace($originalString, '^([^,]*),.*$' , '$1')"/>
    </xsl:function>
    
    <xsl:function name="o2j:getGivenNamesFromTokenizedAuthor" as="xs:string">
        <xsl:param name="originalString" as="xs:string"/>
        <xsl:value-of select="normalize-space(replace($originalString, '^.*,(.*)$' , '$1'))"/>
    </xsl:function>
    
    <xsl:function name="o2j:getSurnameFromTokenizedEditor" as="xs:string">
        <xsl:param name="originalString" as="xs:string"/>
        <xsl:value-of select="replace($originalString, '.*?\s*([^.]+)$' , '$1')"/>
    </xsl:function>
    
    <xsl:function name="o2j:getGivenNamesFromTokenizedEditor" as="xs:string">
        <xsl:param name="originalString" as="xs:string"/>
        <xsl:value-of select="normalize-space(replace($originalString, '^((\c\.\s?)+).*?$' , '$1'))"/>
    </xsl:function>
    
    <xsl:function name="o2j:getFirstChar" as="xs:string">
        <xsl:param name="originalString" as="xs:string"/>
        <xsl:value-of select="replace($originalString, '^(\c).*$' , '$1')"/>
    </xsl:function>
    
    <xsl:function name="o2j:getCaps" as="xs:string">
        <xsl:param name="originalString" as="xs:string"/>
        <!-- delete all characters that are not uppercase letters and return string -->
        <xsl:value-of select="replace($originalString, '\P{Lu}' , '')"/>
    </xsl:function>

    <xsl:function name="o2j:createRefId" as="xs:string">
        <xsl:param name="authors" as="node()*"/>
        <xsl:param name="year" as="xs:string"/>
        <xsl:variable name="authorSurnameCaps">
            <xsl:for-each select="$authors/person-group/name">
                <xsl:value-of select="o2j:getCaps(./surname)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="concat($authorSurnameCaps, $year)"/>
    </xsl:function>
    
    <xsl:function name="o2j:generate_id_for_mixed_citation" as="xs:string">
        <xsl:param name="mixed_citation" as="node()"></xsl:param>
        <xsl:variable name="mixed_citation_string_value"><xsl:value-of select="$mixed_citation"/></xsl:variable>
        <xsl:variable name="authors_and_year" select="replace($mixed_citation_string_value, '^[^)]+[)].+$' ,'$1' )"/>
        <!--<xsl:value-of select="$authors_and_year"/>-->
        <xsl:value-of select="'##ID##'"/>
    </xsl:function>
    
    
</xsl:stylesheet>