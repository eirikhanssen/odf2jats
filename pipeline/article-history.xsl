<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs m" version="2.0"
    xmlns:m="https://github.com/eirikhanssen/odf2jats/months">

    <xsl:function name="m:monthToInt" as="xs:integer">
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

    <xsl:template match="history">
        <xsl:variable name="date-format" as="xs:string?">
            <xsl:choose>
                <xsl:when test="matches(. , '^.*?\d\d?\s*\c+\s*\d{4}\s*$')">dd_textmonth_yyyy</xsl:when>
                <xsl:when test="matches(. , '^.*?\d\d?\s*\d\d?\s*\d{4}\s*$')">dd_mm_yyyy</xsl:when>
                <xsl:when test="matches(. , '^.*?\d{4}\s*\d\d?\s*\d\d?$')">yyyy_mm_dd</xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="date-type" as="xs:string?">
            <xsl:choose>
                <xsl:when test="matches(. , 'Received')">received</xsl:when>
                <xsl:when test="matches(. , 'Accepted')">accepted</xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="year" select="xs:integer(replace( . , '^.*?(\d{4}).*?$' , '$1'))" as="xs:integer"/>
        <xsl:variable name="month" as="xs:integer">
            <xsl:if test="not(empty($date-format))">
                <xsl:choose>
                    <xsl:when test="$date-format = 'dd_textmonth_yyyy'">
                        <xsl:variable name="monthstring_lowercase"
                            select="lower-case(substring(replace(. , '^.*?\d\d?\s*(\c+)\s*\d{4}\s*$' , '$1'), 1 , 3))"
                            as="xs:string"/>
                        <xsl:value-of select="m:monthToInt($monthstring_lowercase)"/>
                    </xsl:when>
                    <xsl:when test="$date-format = 'dd_mm_yyyy'">
                        <xsl:value-of select="xs:integer(replace(. , '^.*?\d\d?\s*(\d\d?)\s*\d{4}\s*$' , '$1'))"
                        />
                    </xsl:when>
                    <xsl:when test="$date-format = 'yyyy_mm_dd'">
                        <xsl:value-of select="xs:integer(replace(. , '^.*?\d{4}\s*(\d\d?)\s*\d\d?$' , '$1'))"/>
                    </xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>

        <xsl:variable name="day" as="xs:integer">
            <xsl:if test="not(empty($date-format))">
                <xsl:choose>
                    <xsl:when test="$date-format = 'dd_textmonth_yyyy'">
                        <xsl:value-of select="xs:integer(replace(. , '^.*?(\d\d?)\s*\c+\s*\d{4}\s*$', '$1'))"/>
                    </xsl:when>
                    <xsl:when test="$date-format = 'dd_mm_yyyy'">
                        <xsl:value-of select="xs:integer(replace(. , '^.*?\d\d?\s*(\d\d?)\s*\d{4}\s*$' , '$1'))"/>
                    </xsl:when>
                    <xsl:when test="$date-format = 'yyyy_mm_dd'">
                        <xsl:value-of select="xs:integer(replace(. , '^.*?\d{4}\s*(\d\d?)\s*\d\d?$' , '$1'))"/>
                    </xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>

        <date>
            <xsl:attribute name="date-type">
                <xsl:value-of select="$date-type"/>
            </xsl:attribute>
            <day>
                <xsl:choose>
                    <xsl:when test="$day > 0 and $day &lt;= 31">
                        <xsl:value-of select="$day"/>
                    </xsl:when>
                    <xsl:otherwise>
<!--                        <xsl:message>Notice: day out of range for <xsl:value-of select="$date-type"/>-date = <xsl:value-of select="concat($year, '-' , $month, '-' , $day )"></xsl:message>-->
                        <xsl:text>____</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </day>
            <month>
                <xsl:choose>
                    <xsl:when test="$month > 0 and $month &lt;= 12">
                        <xsl:value-of select="$month"/>
                    </xsl:when>
                    <xsl:otherwise>
<!--                        <xsl:message>Notice: month out of range for <xsl:value-of select="$date-type"/>-date = <xsl:value-of select="concat($year, '-' , $month, '-' , $day )"></xsl:message>-->
                        <xsl:text>____</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </month>
            <year>
                <xsl:choose>
                    <xsl:when test="$year &lt; 2010 or $year > year-from-date(current-date())">
                        <xsl:value-of select="$year"/>
<!--                        <xsl:message>Notice: Please verify - Year possibly out of range for <xsl:value-of select="$date-type"/>-date = <xsl:value-of select="concat($year, '-' , $month, '-' , $day )"></xsl:value-of> is correct.</xsl:message>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$year"/>
                    </xsl:otherwise>
                </xsl:choose>
            </year>
        </date>

    <!--should display messages for illegal day/month values also-->

    </xsl:template>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
