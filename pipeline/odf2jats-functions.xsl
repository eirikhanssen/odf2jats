<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0"
    xmlns:o2j="https://github.com/eirikhanssen/odf2jats">
    
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
    
</xsl:stylesheet>