<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
    xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
    xmlns:sm="https://github.com/eirikhanssen/odf2jats/stylemap"
    xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
    xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
    exclude-result-prefixes="xs sm style office text table fo draw svg">

    <xsl:output method="xml" indent="yes"/>

    <xsl:variable name="styles"
        select="doc('')/xsl:stylesheet/sm:styles/sm:style" as="element(sm:style)+"/>

    <xsl:variable name="automatic-styles"
        select="/office:document-content/office:automatic-styles/style:style"
        as="element(style:style)+"/>

    <xsl:template match="/">
        <article article-type="research-article">
            <xsl:apply-templates/>
        </article>
    </xsl:template>

    <xsl:template match="text:p">
        <!-- Use the style mapping lookup to define the styles -->
        
        <xsl:variable
            name="current_style_index_name"
            select="if(current()/@text:style-name) then (current()/@text:style-name) else('')"
            as="xs:string"/>
        
        <xsl:variable name="current_automatic_style"
            select="/office:document-content/office:automatic-styles/style:style[@style:name=$current_style_index_name]" 
            as="element(style:style)?"/>

        <xsl:variable name="current_stylename" 
            select="
                if (matches(current()/@text:style-name, '^P\d'))
                then ($current_automatic_style/@style:parent-style-name)
                else (
                    if(current()/@text:style-name) then (current()/@text:style-name) else('')
                )
            " as="xs:string"/>

        <xsl:variable name="elementName" select="
            if ($styles[sm:name=$current_stylename]/sm:transformTo) (: check if current style is in stylemap :)
            then ($styles[sm:name=$current_stylename]/sm:transformTo) (: found current style in stylemap and use it for lookup :)
            else ('') (: If current style is not found in the stylemap, return empty string :)
            " as="xs:string"/>

        <xsl:choose>
            <!-- if text:p is empty, don't output anything -->
            <xsl:when test=".='' and not(element())">
                <xsl:message>removed empty element: text:p</xsl:message>
            </xsl:when>
            <xsl:when test="$elementName = 'p' and
                $current_automatic_style/style:text-properties[@fo:font-style='italic']">
                    <xsl:element name="{$elementName}">
                        <italic><xsl:apply-templates/></italic>
                    </xsl:element>
            </xsl:when>
            <xsl:when test="$elementName !=''">
                <xsl:element name="{$elementName}">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- paragraphs without a style in the style-mapping should just transform to p elements -->
                    <xsl:element name="p">
                        <xsl:if test="matches($current_stylename, '[^\s]+')">
                            <xsl:attribute name="style">
                                <xsl:value-of select="$current_stylename"/>
                            </xsl:attribute>
                            <xsl:message>
                                <xsl:text>Not mapped - text:p[@style='</xsl:text>
                                <xsl:value-of select="$current_stylename"/>
                                <xsl:text>'] &#xa;Textcontent: </xsl:text>
                                <xsl:value-of select="substring(./text()[1],1,30)"/>
                                <xsl:if test="string-length( . /text()[1]) &gt; 30">
                                    <xsl:text> …</xsl:text>
                                </xsl:if>
                            </xsl:message>
                        </xsl:if>
                        <xsl:apply-templates/>
                    </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="text:list">
        <!-- First, figure out the level of the list -->
        <xsl:variable name="list-level" select="count(./ancestor-or-self::text:list)"/>
        <!--
            Figure out the type of list, and set the optional @list-type=
            "order|bullet|alpha-lower|alpha-upper|roman-lower|roman-upper|simple"
 
            The style name compared here must be the style name of the topmost list, 
            because that's where the styles for all nested lists are contained! 
            
            So we must use the list-level here and count starting from the text:list in focus
            up all ancestor text list to the top text:list, that means $list-level times up,
            and that's the point where we will be able to find the correct list style information.
        -->

        <xsl:variable name="style-name" select="
            if (current()/ancestor-or-self::text:list[$list-level]/@text:style-name)
            then (current()/ancestor-or-self::text:list[$list-level]/@text:style-name)
            else ('')" as="xs:string"/>
        <xsl:variable name="list-type" as="xs:string">
            <xsl:choose>
                <xsl:when test="$style-name != '' and /office:document-content/office:automatic-styles/text:list-style[@style:name = $style-name]">
                    <xsl:variable name="current_list_style" select="/office:document-content/office:automatic-styles/text:list-style[@style:name = $style-name]" as="element(text:list-style)"/>
                    <xsl:choose>
                        <xsl:when test="$current_list_style/element()[$list-level][local-name(.) = 'list-level-style-bullet']">
                            <xsl:text>bullet</xsl:text>
                        </xsl:when>
                        <xsl:when test="$current_list_style/element()[$list-level][local-name(.) = 'list-level-style-number']">
                            <xsl:variable name="num-format" select="$current_list_style/element()[$list-level]/@style:num-format"/>
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
    
    <!-- insert a | character when encountering text:tab in a p that has the paragraph style ArticleIdentifiers -->
    <xsl:template match="text:tab[ancestor::text:p[@text:style-name='ArticleIdentifiers']]"><xsl:text>|</xsl:text></xsl:template>

    <xsl:template match="text:list-item">
        <list-item><xsl:apply-templates/></list-item>
    </xsl:template>
    
    <!--
        footnotes and endnotes are mapped to xref and fn elements used in JATS
        in the place where the footnote/endnote is located in odf.
        Later in the pipeline all the fn elements (that are not part of a table's footnote group)
        should be put in the back/fn-group section, leaving just the xref elements referring to the
        footnotes in place.
    -->
    <xsl:template match="text:note">
        <sup>
            <xsl:element name="xref">
                <xsl:attribute name="ref-type" select="'fn'"/>
                <xsl:attribute name="rid" select="@text:id"/>
                <xsl:apply-templates select="text:note-citation"/>
            </xsl:element>
        </sup>
        <xsl:element name="fn">
            <xsl:attribute name="id" select="@text:id"/>
            <xsl:apply-templates select="text:note-body"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="text:h">
        <!-- store the outline_level in a variable, default to 1 -->
        <xsl:variable name="outline_level" select="if (current()/@text:outline-level) then (current()/@text:outline-level) else (1)" as="xs:integer"/>
        <xsl:variable name="elementName" as="xs:string">
            <!-- if outline level is 1, check the style name -->
            <xsl:choose>
                <xsl:when test="$outline_level = 1">
                    <xsl:value-of select="
                        if($styles[sm:name=current()/@text:style-name]) 
                        then ($styles[sm:name=current()/@text:style-name]/sm:transformTo) 
                        else (concat('h', $outline_level))"/> 
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('h', $outline_level)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$elementName}">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="table:table">
        <!-- Determine what number table this is in the document order, and use this number when generating table id -->
        <xsl:variable name="table_total_count" select="count(//table:table)" as="xs:integer"/>
        <xsl:variable name="table_after_count" select="count(following::table:table|descendant::table:table)" as="xs:integer"/>
        <xsl:variable name="table_num" select="$table_total_count - $table_after_count" as="xs:integer"/>
        <xsl:variable name="table-id" select="concat('tbl' , string($table_num))" as="xs:string"/>
        <table-wrap id="{$table-id}">
            <label>____</label><xsl:comment> optional label and caption </xsl:comment>
            <caption><p>____</p></caption>
            <table>
                <xsl:apply-templates select="table:table-header-rows"/>
                <tbody>
                    <xsl:apply-templates select="table:table-row[not(parent::table:table-header-rows)]"/>
                </tbody>
            </table>
        </table-wrap>
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

    <xsl:template match="table:table-cell[not(ancestor::table:table-header-rows)]">
        <td>
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xsl:template match="table:table-cell[ancestor::table:table-header-rows]">
        <th>
            <xsl:apply-templates/>
        </th>
    </xsl:template>

    <!-- Preserve italic and bold text -->
    <xsl:template match="text:span">
        <xsl:variable name="mapped-style-def" select="$automatic-styles[@style:name = current()/@text:style-name]/style:text-properties" as="element(style:text-properties)?"/>
        <xsl:variable name="isBold" select="$mapped-style-def/@fo:font-weight='bold'" as="xs:boolean"/>
        <xsl:variable name="isItalic" select="$mapped-style-def/@fo:font-style='italic'" as="xs:boolean"/>
        <xsl:variable name="isSubScript" select="matches($mapped-style-def/@style:text-position, '^sub')" as="xs:boolean"/>
        <xsl:variable name="isSuperScript" select="matches($mapped-style-def/@style:text-position, '^super')" as="xs:boolean"/>
        <xsl:choose>
            <xsl:when test="count($mapped-style-def) = 0">
                <xsl:message>(o2j WARNING): Empty Sequence $mapped-style-def</xsl:message>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="$isBold eq true() and $isItalic eq true() and $isSubScript">
                <sub><bold><italic><xsl:apply-templates/></italic></bold></sub>
            </xsl:when>
            <xsl:when test="$isBold eq true() and $isItalic eq true() and $isSuperScript">
                <sup><bold><italic><xsl:apply-templates/></italic></bold></sup>
            </xsl:when>
            <xsl:when test="$isBold eq true() and $isItalic eq true()">
                <bold><italic><xsl:apply-templates/></italic></bold>
            </xsl:when>
            <xsl:when test="$isBold eq true() and $isSubScript">
                <sub><bold><xsl:apply-templates/></bold></sub>
            </xsl:when>
            <xsl:when test="$isBold eq true() and $isSuperScript">
                <sup><bold><xsl:apply-templates/></bold></sup>
            </xsl:when>
            <xsl:when test="$isBold eq true()">
                <bold><xsl:apply-templates/></bold>
            </xsl:when>
            <xsl:when test="$isItalic eq true() and $isSubScript">
                <sub><italic><xsl:apply-templates/></italic></sub>
            </xsl:when>
            <xsl:when test="$isItalic eq true() and $isSuperScript">
                <sup><italic><xsl:apply-templates/></italic></sup>
            </xsl:when>
            <xsl:when test="$isItalic eq true()">
                <italic><xsl:apply-templates/></italic>
            </xsl:when>
            <xsl:when test="$isSubScript eq true()">
                <sub><xsl:apply-templates/></sub>
            </xsl:when>
            <xsl:when test="$isSuperScript eq true()">
                <sup><xsl:apply-templates/></sup>
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- mark up links -->
    <xsl:template match="text:a[@xlink:href]">
        <uri><xsl:value-of select="@xlink:href"/></uri>
    </xsl:template>

    <xsl:template match="draw:frame">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Graphics -->
    <xsl:template match="draw:frame[draw:image]">
        <xsl:text>&#xa;</xsl:text>
        <label>
            <xsl:choose>
                <xsl:when test="@draw:name">
                    <xsl:value-of select="@draw:name"/>
                </xsl:when>
                <xsl:when test="matches(./text()  , '^\c\s*\d+:\s*.+$')">
                    <xsl:value-of select="replace(./text() , '^(\c\s*\d+):\s*.+$' , '$1')"/>
                </xsl:when>
                <xsl:otherwise><xsl:text>____</xsl:text></xsl:otherwise>
            </xsl:choose>
        </label>
        <caption>
            <p>
                <xsl:choose>
                    <xsl:when test="svg:title">
                        <xsl:value-of select="svg:title"/>
                    </xsl:when>
                    <xsl:when test="matches(./text()  , '^\c\s*\d+:\s*.+$')">
                        <xsl:value-of select="replace(./text() , '^\c\s*\d+:\s*(.+)$' , '$1')"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:text>____</xsl:text></xsl:otherwise>
                </xsl:choose>
                </p>
        </caption>
            <xsl:for-each select="draw:image">
                <graphic>
                    <xsl:sequence select="@xlink:href"/>
                </graphic>
            </xsl:for-each>
    </xsl:template>

    <!-- preserve tabs -->
    <xsl:template match="text:tab"><xsl:text>&#x09;</xsl:text></xsl:template>

    <!-- Stylemap - map styles to elements -->
    <sm:styles>
        <sm:style>
            <sm:name>Standard</sm:name>
            <sm:name>Text_20_body</sm:name>
            <sm:name>List_20_Contents</sm:name>
            <sm:name>Footnote</sm:name>
            <sm:name>Endnote</sm:name>
            <sm:transformTo>p</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>RefListRef</sm:name>
            <sm:transformTo>ref</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Title</sm:name>
            <sm:name>PP_20_Heading_20_1</sm:name>
            <sm:name>H1-ArticleTitle</sm:name>
            <sm:transformTo>article-title</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Heading_20_1</sm:name>
            <sm:transformTo>h1</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Heading_20_2</sm:name>
            <sm:name>PP_20_Heading_20_2</sm:name>
            <sm:transformTo>h2</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Heading_20_3</sm:name>
            <sm:name>PP_20_Heading_20_3</sm:name>
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
            <sm:name>Sender</sm:name>
            <sm:name>ArticleAuthors</sm:name>
            <sm:transformTo>authors</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Abstract</sm:name>
            <sm:name>ArticleAbstract</sm:name>
            <sm:transformTo>abstract</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>Keywords</sm:name>
            <sm:name>ArticleKeywords</sm:name>
            <sm:transformTo>keywords</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>ArticleContactInfo</sm:name>
            <sm:transformTo>contact-info</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>ArticleHistory</sm:name>
            <sm:transformTo>history</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>ArticleIdentifiers</sm:name>
            <sm:transformTo>article-identifiers</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>FigLabel</sm:name>
            <sm:transformTo>fig_label</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>FigCaption</sm:name>
            <sm:transformTo>fig_caption</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>FigLabelCaptionGraphic</sm:name>
            <sm:transformTo>figure_with_label_caption_graphic</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>TableLabel</sm:name>
            <sm:transformTo>table_label</sm:transformTo>
        </sm:style>
        <sm:style>
            <sm:name>TableCaption</sm:name>
            <sm:transformTo>table_caption</sm:transformTo>
        </sm:style>
    </sm:styles>
</xsl:stylesheet>
