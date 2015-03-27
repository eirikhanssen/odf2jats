<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns:j2e="https://github.com/eirikhanssen/jats2epub"
    xmlns:sm="https://github.com/eirikhanssen/odf2jats/stylemap"
    exclude-result-prefixes="xs xlink j2e sm style office text table">

    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="styles" select="doc('')/xsl:stylesheet/sm:styles/sm:style"
        as="element(sm:style)+"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="office:document-content">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="office:body">
            <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="text:p">
    <!-- Use the style mapping lookup to define the styles -->
        <xsl:variable name="current_style_index_name" select="current()/@text:style-name"
            as="xs:string"/>
        <xsl:variable name="current_automatic_style"  select="/office:document-content/office:automatic-styles/style:style[@style:name=$current_style_index_name]" as="element(style:style)?"/>
        <xsl:variable name="current_stylename" select="
            if (matches(current()/@text:style-name, '^P\d'))
            then ($current_automatic_style/@style:parent-style-name)
            else (current()/@text:style-name)
            " as="xs:string"/>

        <xsl:variable name="elementName" select="
            if ($styles[sm:name=$current_stylename]/sm:transformTo) (: check if current style is in stylemap :)
            then ($styles[sm:name=$current_stylename]/sm:transformTo) (: found current style in stylemap and use it for lookup :)
            else ('') (: If current style is not found in the stylemap, return empty string :)
            " as="xs:string"/>

        <xsl:choose>
            <xsl:when test="$elementName !=''">
                <xsl:element name="{$elementName}">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- paragraphs without a listed style are just plain p's -->
                <!-- generate this p-element only if there is textcontent and it contains non-whitespace characters -->
                <xsl:if test="matches(. , '[^\s]')">
                    <xsl:element name="p">
                        <xsl:attribute name="style">
                            <xsl:value-of select="$current_stylename"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="text:list">
        <!--
            Try and figure out the type of list, and set the optional @list-type=
            "order|bullet|alpha-lower|alpha-upper|roman-lower|roman-upper|simple"
        -->
        <xsl:variable name="style-name" select="if (@text:style-name) then (@text:style-name) else ('')" as="xs:string"/>
        <xsl:variable name="list-type" as="xs:string">
            <xsl:choose>
                <xsl:when test="$style-name != '' and /office:document-content/office:automatic-styles/text:list-style[@style:name = $style-name]">
                    <xsl:variable name="current_list_style" select="/office:document-content/office:automatic-styles/text:list-style[@style:name = $style-name]" as="element(text:list-style)"/>
                    <xsl:choose>
                        <xsl:when test="$current_list_style/text:list-level-style-bullet">
                            <xsl:text>bullet</xsl:text>
                        </xsl:when>
                        <xsl:when test="$current_list_style/text:list-level-style-number">
                            <xsl:variable name="num-format" select="$current_list_style/text:list-level-style-number[1]/@style:num-format"/>
                            <xsl:choose>
                                <xsl:when test="$num-format = 'a'">alpha-lower</xsl:when>
                                <xsl:when test="$num-format = 'A'">alpha-upper</xsl:when>
                                <xsl:when test="$num-format = 'i'">roman-lower</xsl:when>
                                <xsl:when test="$num-format = 'I'">roman-upper</xsl:when>
                                <xsl:otherwise>order</xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'undefined'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="list">
            <xsl:if test="$list-type != 'undefined'">
                <xsl:attribute name="list-type">
                    <xsl:value-of select="$list-type"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="text:h">
        <!-- store the outline_level in a variable, default to 1 -->
        <xsl:variable name="outline_level" select="if (current()/@text:outline-level) then (current()/@text:outline-level) else ('1')" as="xs:string"/>
        <xsl:variable name="elementName" select="concat('h', $outline_level)" as="xs:string"/>
        <xsl:element name="{$elementName}">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="table:table">
        <table>
            <xsl:apply-templates select="table:table-header-rows"/>
            <tbody>
                <xsl:apply-templates select="table:table-row[not(parent::table:table-header-rows)]"
                />
            </tbody>
        </table>
    </xsl:template>

    <xsl:template match="table:table-header-rows">
        <thead>
            <xsl:apply-templates/>
        </thead>
    </xsl:template>

    <xsl:template match="table:table-row">
        <tr>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="table:table-cell">
        <td>
            <xsl:apply-templates mode="table-cell"/>
        </td>
    </xsl:template>

    <xsl:template match="table:table-cell[ancestor::table:table-header-rows]">
        <th>
            <xsl:apply-templates mode="table-cell"/>
        </th>
    </xsl:template>

    <xsl:template match="table:table-cell/text:p"> </xsl:template>

    <xsl:template match="table:table-cell/text:p" mode="table-cell">
        <xsl:apply-templates/>
    </xsl:template>

    <!--<xsl:template match="*">
        <xsl:message>undefined element: <xsl:value-of select="local-name(.)"/>"</xsl:message>
    </xsl:template>-->

    <!-- Stylemap - map styles to elements -->
    <sm:styles>
        <sm:style>
            <sm:name>Standard</sm:name>
            <sm:name>Text_20_body</sm:name>
            <sm:transformTo>p</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>List_20_Contents</sm:name>
            <sm:transformTo>list-item</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Heading_20_1</sm:name>
            <sm:name>FauxHeading1WithoutOutline</sm:name>
            <sm:transformTo>h1</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Heading_20_2</sm:name>
            <sm:transformTo>h2</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Heading_20_3</sm:name>
            <sm:transformTo>h3</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Heading_20_4</sm:name>
            <sm:transformTo>h4</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Heading_20_5</sm:name>
            <sm:transformTo>h5</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Heading_20_6</sm:name>
            <sm:transformTo>h6</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Subtitle</sm:name>
            <sm:transformTo>subtitle</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Title</sm:name>
            <sm:transformTo>article-title</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Sender</sm:name>
            <sm:transformTo>authors</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Abstract</sm:name>
            <sm:transformTo>abstract</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Keywords</sm:name>
            <sm:transformTo>keywords</sm:transformTo>
        </sm:style>
    </sm:styles>
</xsl:stylesheet>
