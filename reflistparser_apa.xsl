﻿<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:o2j="https://github.com/eirikhanssen/odf2jats"
  exclude-result-prefixes="xs xlink j2e">

  <xsl:output method="xml" indent="yes"/>

  <!-- 'debug=on|true|1' can be specified as a paramenter during runtime, and then debug output will be shown -->
  <xsl:param name="debug" as="xs:string">off</xsl:param>

  <xsl:variable name="debugMode" as="xs:boolean">
    <!-- decide if debugMode is on or off and assign true or false boolean to $debugMode variable -->
    <!-- case insensitive match using the "i" flag -->
    <xsl:value-of select="matches($debug , '^(on|true|1|yes)$' , 'i')"/>
  </xsl:variable>

  <xsl:function name="o2j:replaceAmpInAuthorstring" as="xs:string">
    <xsl:param name="originalString" as="xs:string"/>
    <!-- replace the &amp; (preceeded by comma and optional space) before the last author in authorstring with comma -->
    <!-- then different authors in the authorstring will be separated by (last initial) (dot) (comma) -->
    <xsl:value-of select="replace($originalString, ',*?\s*&amp;' , ',')"/>
  </xsl:function>

  <xsl:function name="o2j:normalizeEditorString" as="xs:string">
    <xsl:param name="originalString" as="xs:string"/>

    <!--  E.M => E. M -->
    <xsl:variable name="editorStringFix1">
      <xsl:value-of select="replace($originalString , '(\c)\.(\c)' , '$1. $2')"/>
    </xsl:variable>

    <!-- Make sure initials have a dot following: E. M => E. M.-->
    <xsl:variable name="editorStringFix2">
      <xsl:value-of select="replace($editorStringFix1 , '\s(\c)\s' , ' $1. ')"/>
    </xsl:variable>

    <!-- Replace &amp; surrounded by optional space with comma followed by exactly one space -->
    <!-- E. M. Hanssen &amp; E. De Silva  => E. M. Hanssen, E. De Silva -->
    <xsl:variable name="editorStringFix3">
      <xsl:value-of select="replace($editorStringFix2 , '\s*&amp;\s*' , ', ')"/>
    </xsl:variable>

    <xsl:value-of select="$editorStringFix3"/>
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
    <xsl:value-of
      select="o2j:prepareTokens(o2j:replaceAmpInAuthorstring(o2j:normalizeInitialsInAuthorstring($originalString)))"
    />
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

  <xsl:function name="o2j:createRefId" as="xs:string">
    <xsl:param name="authors" as="node()*"/>
    <xsl:param name="year" as="xs:string"/>

    <xsl:variable name="authorInitials">
      <xsl:for-each select="$authors/person-group/name">
        <xsl:value-of select="o2j:getFirstChar(./surname)"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="concat($authorInitials, $year)"/>
  </xsl:function>

  <xsl:function name="o2j:createRefId" as="xs:string">
    <xsl:param name="year" as="xs:string"/>
    <xsl:value-of select="$year"/>
  </xsl:function>

  <xsl:function name="o2j:getChapterTitle" as="xs:string">
    <!-- 
      Return string with chapter title. Needs node with raw reference as param. 
      Grabs the text between "({year}) " and ". In {Initial}" -->
    <xsl:param name="originalRef" as="node()"/>
    <xsl:variable name="chapterTitle" select="replace($originalRef, '.*?\(\d{4}\)\.?\s*(.+?)\.?\sIn\s\p{Lu}\..*', '$1')"/>
    <xsl:value-of select="$chapterTitle"/>
  </xsl:function>

  <xsl:function name="o2j:getSourceTitle" as="xs:string">
    <!-- Return string with chapter title. Needs node with raw reference as param.
      Will use the text content in <italic> elements and do some regex checking to see if it is the title. -->
    <xsl:param name="originalRef" as="node()"/>

    <!-- WIP needs more testing -->

    <!-- WIP when translation follows <italic>...</italic> in [Brackets] it should be marked up as trans source. -->
    <xsl:value-of select="normalize-space($originalRef/italic[1])"/>

  </xsl:function>

  <xsl:function name="o2j:getPublisherString" as="xs:string">
    <xsl:param name="originalString" as="xs:string"/>
    <!-- Extract publisher string from a book type reference in a reference list -->
    <!-- This function assumes $originalString to be of a book type reference; a ref that is tested to be $isBook eq true() -->
    <!-- It's important to use the lazy/non-greedy quantifiers such as *? as opposed to *
         to get the shortest possible match and not the longest possible match -->
    <!-- $1 with preceeding regex is important to allow publisher-loc such as {New York, NY: Wiley} -->
    <!-- $2 makes {, } optional, so publisher-loc such as {New York: Basic Books.} is also correctly matched. 
         This grouping should not be carried over to the output -->
    <!-- $3 allows forward-slash in publisher-loc as in {Stockholm/Stehag: Symposion.} -->
    <!-- the negated character class [^:] in $3 is important in order to match text only around the last colon
         in the case where a colon might be used earlier in the string -->
    <xsl:value-of
      select="normalize-space(replace($originalString , '.*?[,.\]]?\s+([^,.\]]*?\c\c+(,\s)?)?([\c/]{2,}:[^:]*?)$' , '$1$3'))"
    />
  </xsl:function>

  <xsl:function name="o2j:getPublisherLoc" as="xs:string">
    <xsl:param name="publisherString" as="xs:string"/>
    <!-- Get all text before colon -->
    <xsl:value-of select="normalize-space(replace($publisherString, '^([^:]*?):.*', '$1'))"/>
  </xsl:function>

  <xsl:function name="o2j:getPublisherName" as="xs:string">
    <xsl:param name="publisherString" as="xs:string"/>
    <!-- Get all text after colon, but leave out optional dot in the end -->
    <xsl:value-of select="normalize-space(replace($publisherString, '.*?:([^:]*?)\.?$', '$1'))"/>
  </xsl:function>

  <xsl:function name="o2j:getEditorString" as="xs:string">
    <xsl:param name="originalString" as="xs:string"/>
    <xsl:value-of
      select="replace($originalString , '^.*?In([^()]*?)[,.\s]*?\((RE|E)ds?\.\).*$' , '$1' )"/>
  </xsl:function>

  <xsl:function name="o2j:prepareTokensInEditorString" as="xs:string">
    <xsl:param name="originalString" as="xs:string"/>
    <xsl:value-of select="replace($originalString , '(,\s?)' , '|' )"/>
  </xsl:function>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="ref-list">
    <ref-list>
      <xsl:for-each select="ref">
        <xsl:call-template name="refparser"/>
      </xsl:for-each>
    </ref-list>
  </xsl:template>

  <xsl:template name="refparser">

    <xsl:variable name="textcontent" select="."/>

    <xsl:variable name="year">
      <xsl:analyze-string select="$textcontent" regex=".*\(([0-9]{{4}})\)">
        <xsl:matching-substring>
          <xsl:value-of select="regex-group(1)"/>
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:variable>

    <xsl:variable name="authors">
      <xsl:analyze-string select="$textcontent" regex="(..*)\(\d{{4}}\)">
        <xsl:matching-substring>
          <xsl:value-of select="regex-group(1)"/>
        </xsl:matching-substring>
      </xsl:analyze-string>
    </xsl:variable>

    <xsl:variable name="isParsableAuthorString" as="xs:boolean">
      <xsl:value-of select="matches($authors, '^\s*[\c][\c]*,\s*[\c]')"/>
    </xsl:variable>

    <xsl:variable name="tokenizedAuthors" as="xs:string">
      <xsl:value-of select="o2j:tokenizeAuthors($authors)"/>
    </xsl:variable>

    <xsl:variable name="isBook" as="xs:boolean">
      <!-- Check if the end of the reference to see if it ends with a typical book type reference to a publisher -->
      <!-- Allow some flexibility in publisher-name and publisher-loc such as spaces, slash, hyphen -->
      <!-- Example publisher strings that should match:
          [(...) Malmö: Liber.] 
          [(...) Cambridge: Polity Press.]
          [(...) Stockholm/Stehag: Symposion.]
          [(...) Stockholm: Sveriges Kommuner och Landsting.]
      -->
      <xsl:value-of select="matches($textcontent, '[-\c/]{2,}:\s+[-\c\s/]{2,}.?$')"/>
    </xsl:variable>

    <xsl:variable name="isBookChapter" as="xs:boolean">
      <xsl:value-of select="matches($textcontent, '((Re|E)ds?\.)')"/>
    </xsl:variable>
    
    <xsl:variable name="hasTranslatedBookTitle" select="matches($textcontent/italic[1]/following-sibling::text()[1] , '^.*?\[(.+?)\].*$')" as="xs:boolean"/>
    
    <xsl:variable name="translatedBookTitle" as="xs:string">
      <xsl:choose>
        <xsl:when test="$hasTranslatedBookTitle eq true()">
          <xsl:value-of select="replace($textcontent/italic[1]/following-sibling::text()[1] , '^.*?\[(.+?)\].*$' , '$1')"></xsl:value-of>
        </xsl:when>
        <xsl:otherwise><xsl:if test="$isBook eq false()">NotIdentifiedAsBook</xsl:if><xsl:text>TranslatedSourceNotFound</xsl:text></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="hasTranslatedBookChapterTitle" select="matches(o2j:getChapterTitle($textcontent) , '\[[^\]]+?\]')" as="xs:boolean"/>


    <xsl:variable name="hasSinglePageCountStringInParens" as="xs:boolean">
      <xsl:value-of select="matches ($textcontent , '\(.*?p?p\.\s*\d+.*?\)') and not(matches($textcontent, '\(.*?pp\.\s*\d+\s*-\s*\d+.*?\)'))"/>
    </xsl:variable>

    <xsl:variable name="hasMultiplePageCountStringInParens" as="xs:boolean">
      <xsl:value-of select="matches($textcontent, '\(.*?pp\.\s*\d+\s*-\s*\d+.*?\)')"/>
    </xsl:variable>

    <xsl:variable name="editorString">
      <xsl:if test="$isBookChapter eq true()">
        <xsl:value-of select="normalize-space(o2j:getEditorString($textcontent))"/>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="tokenizedEditors" as="xs:string">
      <xsl:value-of
        select="o2j:prepareTokensInEditorString(o2j:normalizeEditorString($editorString))"/>
    </xsl:variable>

    <xsl:variable name="isParsableEditorString" as="xs:boolean">
      <xsl:value-of
        select="matches(
          o2j:normalizeEditorString($editorString) ,
            '((\c.\s)+([-\c]{2,}(,|\s)?)+)'
        )"/>
      <!-- WIP placeholder for matches() -->
    </xsl:variable>

    <!-- WIP placeholder hasParsablePublisherString  -->

    <!-- WIP placeholder isParsablePublisherString -->

    <!-- WIP placeholder isParsableEditorString -->

    <xsl:variable name="hasYearInParanthesis" as="xs:boolean">
      <xsl:value-of select='matches($textcontent, ".*\([0-9]{4}\).*")'/>
    </xsl:variable>

    <!-- unknown ref types will be marked up as mixed citation, that means all ref types that
    will not be automatically identified as either book, book-chapter or journal article -->
    <!-- WIP this test needs to be revisited -->
    <xsl:variable name="isUnknownRefType" as="xs:boolean">
      <xsl:value-of
        select="not($hasYearInParanthesis) or not($isParsableAuthorString) or not($isBook)"/>
    </xsl:variable>

    <xsl:variable name="taggedAuthors">
      <xsl:choose>
        <xsl:when test="$isParsableAuthorString eq true()">
          <!-- process $authors -->
          <person-group person-group-type="author">
            <xsl:for-each select="tokenize($tokenizedAuthors, '\|')">
              <xsl:variable name="author" select="normalize-space(.)"/>
              <name>
                <surname>
                  <xsl:value-of select="o2j:getSurnameFromTokenizedAuthor($author)"/>
                </surname>
                <given-names>
                  <xsl:value-of select="o2j:getGivenNamesFromTokenizedAuthor($author)"/>
                </given-names>
              </name>
            </xsl:for-each>
          </person-group>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="taggedEditors">
      <xsl:choose>
        <xsl:when test="$isParsableEditorString eq true()">
          <!-- WIP placeholder process $editors -->
          <person-group person-group-type="editor">
            <xsl:for-each select="tokenize($tokenizedEditors, '\|')">
              <xsl:variable name="editor" select="normalize-space(.)"/>
              <name>
                <surname>
                  <xsl:value-of select="o2j:getSurnameFromTokenizedEditor($editor)"/>
                </surname>
                <given-names>
                  <xsl:value-of select="o2j:getGivenNamesFromTokenizedEditor($editor)"/>
                </given-names>
              </name>
            </xsl:for-each>
          </person-group>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="publisher">
      <xsl:choose>
        <xsl:when test="$isBook eq true()">
          <publisher-loc>
            <xsl:value-of select="o2j:getPublisherLoc(o2j:getPublisherString($textcontent))"/>
          </publisher-loc>
          <publisher-name>
            <xsl:value-of select="o2j:getPublisherName(o2j:getPublisherString($textcontent))"/>
          </publisher-name>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="publication-info">
      <attributes>
        <!-- publication-type: book-chapter|book|journal -->
        <xsl:if test="$isBook eq true()">
          <xsl:attribute name="publication-type">
            <xsl:choose>
              <xsl:when test="$isBookChapter eq true()">
                <xsl:text>book-chapter</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>book</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>

        <!-- publication-format: print|web -->
        <xsl:attribute name="publication-format">
          <xsl:choose>
            <xsl:when test="ext-link">
              <xsl:text>web</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>print</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </attributes>
    </xsl:variable>

    <xsl:element name="ref">
      <xsl:attribute name="id">
        <xsl:choose>
          <xsl:when test="$isUnknownRefType eq false()">
            <xsl:value-of select="o2j:createRefId($taggedAuthors, $year)"/>
          </xsl:when>
          <xsl:when test="$hasYearInParanthesis eq true()">
            <xsl:text>___ </xsl:text>
            <xsl:value-of select="$year"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>___</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <!-- The original, unchanged reference will be inserted in a comment to compare with the autotagged text -->
      <xsl:comment><xsl:apply-templates mode="comment"/></xsl:comment>

      <xsl:choose>
        <xsl:when test="$isUnknownRefType eq true()">
          <xsl:element name="mixed-citation">
            <xsl:copy-of select="$publication-info/attributes/@*"/>
            <xsl:apply-templates/>
          </xsl:element>
        </xsl:when>

        <xsl:when test="$isUnknownRefType eq false()">
          <xsl:element name="element-citation">
            <xsl:copy-of select="$publication-info/attributes/@*"/>
            <xsl:apply-templates select="$taggedAuthors"/>
            <xsl:choose>
              <xsl:when test="$isBook eq true()">
                <xsl:choose>
                  <xsl:when test="$isBookChapter eq true()">
                    <chapter-title>
                      <xsl:choose>
                        <xsl:when test="$hasTranslatedBookChapterTitle eq true()">
                          <xsl:attribute name="xml:lang">__</xsl:attribute>
                          <!-- remove translation in angle brackets -->
                          <xsl:value-of select="replace(o2j:getChapterTitle($textcontent), '\s*\[[^\]]+?\]', '')"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="o2j:getChapterTitle($textcontent)"/>  
                        </xsl:otherwise>
                      </xsl:choose>
                    </chapter-title>
                    <xsl:if test="$hasTranslatedBookChapterTitle eq true()">
                      <trans-title>
                        <xsl:attribute name="xml:lang">__</xsl:attribute>
                        <!-- extract only the translation in angle brackets -->
                        <xsl:value-of select="replace(o2j:getChapterTitle($textcontent) , '^.*?\[(.+?)\].*$' , '$1')"/>
                      </trans-title>
                    </xsl:if>
                    <xsl:apply-templates select="$taggedEditors"/>
                    <source>
                      <xsl:if test="$hasTranslatedBookTitle eq true()">
                        <xsl:attribute name="xml:lang">__</xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="o2j:getSourceTitle($textcontent)"/>
                    </source>
                    <xsl:if test="$hasTranslatedBookTitle eq true()">
                      <trans-source>
                        <xsl:attribute name="xml:lang">__</xsl:attribute>
                        <xsl:value-of select="replace($textcontent/italic[1]/following-sibling::text()[1] , '^.*?\[(.+?)\].*$' , '$1')"/>
                      </trans-source>
                    </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>
                    <source>
                      <xsl:if test="$hasTranslatedBookTitle eq true()">
                        <xsl:attribute name="xml:lang">__</xsl:attribute>
                      </xsl:if>
                      <xsl:value-of select="o2j:getSourceTitle($textcontent)"/>
                    </source>
                    <xsl:if test="$hasTranslatedBookTitle eq true()">
                      <trans-source>
                        <xsl:attribute name="xml:lang">__</xsl:attribute>
                        <!-- extract only the translation in angle brackets -->
                        <xsl:value-of select="replace($textcontent/italic[1]/following-sibling::text()[1] , '^.*?\[(.+?)\].*$' , '$1')"/>
                      </trans-source>
                    </xsl:if>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
            </xsl:choose>
            <year>
              <xsl:value-of select="$year"/>
            </year>
            <xsl:choose>
              <xsl:when test="$hasMultiplePageCountStringInParens eq true()">
                <fpage><xsl:value-of select="replace($textcontent, '.*?\(.*?pp\.\s*(\d+)\s*-\s*\d+.*?\).*' , '$1')"/></fpage>
                <lpage><xsl:value-of select="replace($textcontent, '.*?\(.*?pp\.\s*\d+\s*-\s*(\d+).*?\).*' , '$1')"/></lpage>
              </xsl:when>
              <xsl:when test="$hasSinglePageCountStringInParens eq true()">
                <fpage><xsl:value-of select="replace($textcontent, '.*?\(.*?p?p\.\s*(\d+).*?\).*' , '$1')"/></fpage>
              </xsl:when>

            </xsl:choose>
            <xsl:if test="$isBook eq true()">
              <publisher-loc>
                <xsl:value-of select="$publisher/publisher-loc"/>
              </publisher-loc>
              <publisher-name>
                <xsl:value-of select="$publisher/publisher-name"/>
              </publisher-name>
            </xsl:if>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <errorInXSLT/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="$debugMode eq true()">
        <xsl:text>&#xa;</xsl:text>
        <debugMode>
          <debug>On</debug>
          <originalRef>
            <xsl:apply-templates/>
          </originalRef>
          <authors>
            <xsl:value-of select="$authors"/>
          </authors>
          <tokenizedAuthors>
            <xsl:value-of select="$tokenizedAuthors"/>
          </tokenizedAuthors>
          <editorstring>
            <xsl:value-of select="$editorString"/>
          </editorstring>
          <normalizedEditorString>
            <xsl:value-of select="o2j:normalizeEditorString($editorString)"/>
          </normalizedEditorString>
          <parsableEditorString>
            <xsl:value-of select="$isParsableEditorString"/>
          </parsableEditorString>
          <tokenizedEditorString>
            <xsl:value-of
              select="o2j:prepareTokensInEditorString(o2j:normalizeEditorString($editorString))"/>
          </tokenizedEditorString>
          <publisherString>
            <xsl:value-of select="o2j:getPublisherString($textcontent)"/>
          </publisherString>
        </debugMode>
      </xsl:if>

    </xsl:element>

  </xsl:template>

  <xsl:template match="ext-link">
    <uri>
      <xsl:value-of select="./@xlink:href"/>
    </uri>
  </xsl:template>

  <xsl:template match="uri">
    <uri>
      <xsl:value-of select="."/>
    </uri>
  </xsl:template>

  <xsl:template match="italic" mode="comment">
    <xsl:text>&lt;italic></xsl:text>
      <xsl:apply-templates/>
    <xsl:text>&lt;/italic></xsl:text>
  </xsl:template>

</xsl:stylesheet>
