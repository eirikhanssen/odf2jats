# odf2jats

Developing an automatic tagging workflow to produce **JATS XML** output from manuscripts in **Open Document Format** (.odt files).

## Open Document Format

Open Document Format is a free ISO-standardized format for documents (.odt file extension), spreadsheets (.ods) presentations and more.
ODF is supported by many programs and used as a native format by the free LibreOffice suite and OpenOffice.org.

## Project goals

To simplify and automate the conversion as known as tagging/marking up of scientific manuscripts 
to be represented in the Journal Archive Tag Suite (JATS) XML tagset.

## Motivation

Marking up manuscripts by hand is very time-consuming. The ODF format is a zipped container with text/xml-files and other files. 

If the manuscripts use a known template and use consistent styling, it is very possible to automatically generate most of the structure and 
semantics needed to mark up a manuscript using the JATS tagset.

By exploiting XSLT 2.0, XPath 2.0 and XProc, it is possible to automate extraction/transformation of the contents from the ODF-format to be 
represented in another XML based format such as JATS. 

By utilizing RegEx pattern-matching that is available in XSLT 2.0 and XPath 2.0 it is possible to identify, tokenize and automatically tag text citations and references in the reference list.

By utilizing XSLT 2.0's grouping capabilities it is possible to properly structure a flat xml document to a proper sectioned document.

## Proper styling of documents

### Preserving the outline

It is important for the manuscript to properly communicate the outline.

For best results, all headers in the original manuscript should be styled using header styles of the appropriate level (and not formatted using character formatting).

The same goes for the text in the manuscript, it should be formatted using paragraph styles.

Then a style-mapping can be tailored to the specific family of manuscripts. 
This style-mapping will be used in generating the structure and semantics needed to mark up the manuscript using the JATS tagset.

## Already implemented/autotagged

### Extraction from the ODF container format
- paragraphs
- lists that can be nested
- tables
- headings (6 levels)
- footnotes: xref pointing to the footnotes are left in the text, and the footnotes are grouped in back/fn-group
- **journal-meta**
    - a template for a journal has been included, it could be changed for different journals by using a parameter to the pipeline
- **article-meta**
    - article title (if it has been styled with title paragraph style in the odt document).
    - article authors (if styled with person paragraph style in the odt document).
    - abstract
    - keywords
- book type references
    - authors
    - source
    - trans-source (if present)
    - fpage
    - lpage
    - publisher-loc
    - publisher-name

- book-chapter type references
    - same as book type references
    - chapter-title
    - trans-title (if present)

### Grouping, sectioning and parsing
- the body contents of the document is properly sectioned using sec/title elements based on the outline level on the headings
- citations in the text are identified by regex pattern matching and marked up as xref elements: ```<xref ref-type="bibr" rid="{autogenerated id}">...</xref>```

## Current work in progress

### Reference list

- Book type references auto-tag almost satisfactory
    - can't handle uri at the end
    - edition should be placed in a ```<comment>2nd ed.</comment>```
- Book-chapter type references auto-tag almost satisfactory
    - can't handle uri at the end

## Todo

### Extraction from the ODF container format to JATS
- figures
- article-meta/history: a change in the source document is needed
- article-meta issue and volume: a change in the source document is needed
- **ref-list**
    - journal article type references haven't been implemented yet
    - fix issues with book-type and book-chapter type references
- tables/appendixes in the back section haven't been properly handled yet
- table labels/titles/captions are not automatically handled yet
    - this can be done automatically if they are styled with a special paragraph style do identify the content as being table label, table title or table caption
- citations in the text that only have year within the parens, have **rid** attributes that misses capital letters from author's surname. This could be extracted from the text node directly before the xref-element, or like now, just let the person doing the conversion manually fix those **rid** attributes.
- clean up reflistparser_apa.xsl to make it more readable and follow Clean Code principles

### Writing and styling aids for editors and authors

- develop document templates for use by editors and authors
- develop document styling guidelines that will help facilitate (semi)automatic conversion from manuscript document to JATS

By exercising some control over the source documents the manuscripts are written in, the automatic conversion can be greatly simplified by 
taking advantage of style mappings from paragraph styles in the document to generate appropriate JATS xml markup.

Therefore, document templates and a style guide should be made available to the authors and editors.

This way, most of the work of identifying how elements in the document should be mapped to JATS will already have been done by the authors,
and odf2jats will do the conversion with minimal need for user input.

## Related projects

The JATS XML file that this project aims to autogenerate is to be used with the jats2epub tool.
I am also working on a solution for automatically tagging Office Open XML documents.

- https://github.com/eirikhanssen/ooxml2jats - automatic tagging using Office Open XML format as a base
- https://github.com/eirikhanssen/jats2epub - generation of HTML fulltext, .epub and optionally .mobi formats from JATS XML source

## How to contribute

If you're interested in this project you can
- fork this project and issue a pull request
- send me a message
