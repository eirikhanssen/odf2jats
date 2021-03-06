# odf2jats

Developing an automatic tagging workflow to produce **JATS XML Publishing 1.1** output from manuscripts in **Open Document Format** (.odt files).

## Open Document Format

Open Document Format is a free ISO-standardized format for documents (.odt file extension), spreadsheets (.ods) presentations and more.
The ODF format is supported by many programs and used as a native format by the free LibreOffice suite and OpenOffice.org.

## Formatting of input files
The input .odt files to odf2jats need to be structured properly, and some special paragraph and header styles are used by odf2jats to determine what type of content the text is to be in jats xml.

## Project goals

### Improve the worflow for Open Access Scholarly Publishing

- simplify and automate conversion from manuscripts to JATS XML
- greatly reduce time required by switching from a manual to a semi-automatic workflow

#### odf2jats xml output
**odf2jats** can produce quite good jats xml markup, but it is still not perfect. The user still has to go through the markup and check/correct tagged references. When using XML editing software such as oxygen, most errors in the references are automatically reported since the xml-document properly references the JATS document type (JATS publishing version 1.1 with MathML3 support by default).

#### JATS
Read more about Journal Article (Publishing) Tag Suite, as known as JATS
- http://jats.nlm.nih.gov/publishing/
- https://jats.nlm.nih.gov/publishing/tag-library/1.1/index.html

## Motivation

### Don't let a person do a machine's job

Marking up manuscripts by hand is very time-consuming. The ODF document format is a zipped container with text/xml-files and other files. 

If the manuscripts use a known template and consistent styling, it is possible to automatically generate most of the structure and 
semantics needed to mark up a manuscript using the JATS tagset.

### Automation using XSLT 2.0 and XProc

Automate extraction/transformation of the contents from the ODF-format to JATS by exploiting XSLT 2.0, XPath 2.0 and XProc.
- Use RegEx pattern-matching in XSLT 2.0 and XPath 2.0 to identify, tokenize and automatically tag text citations and references in the reference list.
- Use XSLT 2.0's grouping capabilities to properly structure a flat xml document to a properly sectioned JATS XML document.

## Proper styling of documents

### Preserving the outline

It is important for the manuscript to properly communicate the outline, or hierarchy of the different headers.

For best results, all headers in the original manuscript should be styled using header 
styles of the appropriate outline level (as opposed to using character formatting to increase font sizes). 

These header styles need to have an outline level set in the style configuration. For the default header-styles this is normally
the case. But if a user creates own header styles, this is something to keep in mind.

#### There can be only one
Only the article title should have a header style with outline level 1, the rest should use header styles with outline lvl 2 and higher.

#### Don't skip levels
It is important not to skip a level to ensure that the headings are properly nested, so a level 3 heading should never be a direct child 
of a lvl 1 heading.

The outline level is used to automatically section the body of the JATS xml in sec/title + other elements.

Text in the manuscript should be styled with the default paragraph style for text.

#### Style mappings
Special passages of text can be styled using custom paragraph styles that when using a style-mapping 
in the odf2jats pipeline can facilitate automatic tagging of certain elements.

This is used when generating markup for content such as:
- abstract
- keywords
- history
- references

### Using character styles

Using character styling where appropriate is also important.
Character styles such as bold, italic, subscript and superscript are all supported.

#### Italic text in references has a special meaning
In the reference list, the proper use of italic character style (to identify the source), is
important to facilitate the reference parsing (APA style).

## Steps taken while preparing manuscripts for odf2jats
These are steps that I do to prepare the document for odf2jats conversion.
This section is subject to change.

- recieve xml-based document format (odf or docx)
- open document with Libre Office Writer
- make sure display of Nonprinting characters is on (View menu)
- import user defined styles from another document that has styles prepared for odf2jats workflow
    - In LibreOffice, bring up the style panel: Format > Styles and Formatting (F11)
    - Click down-arrow in upper right corner of Styles and Formatting panel > Load Styles
    - Check Overwrite (to overwrite styles in the current document with identically named styles from the prepared styles document)
    - Click the button "From File ..." to choose the document to load styles from

- apply odf2jats workflow styles (these are used for automatic conversion)

### 1. Clean up
Remove unneccecary whitespace

#### 1.1 Regex replace in Libre Office, replace with empty string:
This could be done in a xslt stylesheet as well.
- blank lines ^$
- whitespace at end of lines \s*$
- whitespace at the beginning of lines ^\s*

#### 1.2 Remove unwanted paragraph marks
Sometimes the author/editor has inserted extra paragraphs within text units to make it span several lines.
For the purposes of generating a structured document, one text unit needs to be in one paragraph:
- headings, article-title heading in particular
- each reference in the reference list must be in one paragraph and not spread across several paragraphs as 
the paragraph is the unit being parsed to auto-tag the contents in a reference
- Each author's contact information should also be in one paragraph with the author's name

### 2 Apply paragraph/header styles specific to the odf2jats workflow
- ArticleAbstract - one paragraph
- ArticleAuthors - one paragraph, all article authors
- ArticleKeywords - one paragraph
- ArticleIdentifiers - one paragraph with issn,<tab> vol, issue, year <tab> doi-url (copied from pdf)
- ArticleContactInfo - one paragraph for each author + one paragraph for author to contact with address
- ArticleHistory - Two paragraphs, one for received, one for accepted
- Apply Header styles (important that the header styles used have proper outline lvl set)
    - H1-ArticleTitle for article-title
    - H2-H{n} for the rest according to level
- Check lists, figures, tables and apply appropriate styles:
    - FigCaption
    - FigLabel
    - TableCaption
    - TableLabel
    - ListContents (necceceary?)
    - If row(s) in the begninning should be table-header rows > apply TableHeader style

### 3 Prepare to run odf2jats
These steps will be unneccecary to do manually in the future as they will be handled by a shellscript.

- unzip odt-file to a folder
- link to content.xml in odf2jats.xpl (later this will be done using a parameter

## Already implemented/autotagged

### Extraction from the ODF container format
- paragraphs
- lists that can be nested
- tables
- figures
- headings (6 levels)
- footnotes: xref pointing to the footnotes are left in the text, and the footnotes are grouped in back/fn-group
- handling of content in the back section after the reference list (appendix) has been implemented
- **journal-meta**
    - a template for a journal has been included, it could be changed for different journals by using a parameter to the pipeline
- **article-meta**
    - article title (if it has been styled with **H1-ArticleTitle** header style in the odt document).
    - article authors (if styled with **ArticleAuthors** paragraph style in the odt document).
    - abstract (if styled with **ArticleAbstract** paragraph style)
    - keywords (if styled with **ArticleKeywords** paragraph style)
    - history (if styled with **ArticleHistory** paragraph style)
    - if copied in a paragraph and styled with **ArticleIdentifiers** paragraph style:
        - volume
        - issue
        - year
        - self-uri
        - doi 
    - contact-info (if paragraphs have been styled with this style)
- adjacent (following) italic elements with only punctuation or whitespace between are merged in references

- **book/book-chapter type references**
    - authors
    - year
    - source (if book type reference)
    - trans-source (if applicable, book type ref)
    - book-chapter (if book-chapter type reference)
    - trans-title (if applicable)
    - editors (if book-chapter type ref)
    - source (if book-chapter type ref)
    - trans-source (if applicable, book-chapter type ref)
    - edition (if applicable)
    - fpage (if applicable)
    - lpage (if applicable)
    - publisher-loc
    - publisher-name
    - uri (if applicable)

- **journal type references**
    - authors
    - year
    - article-title
    - trans-title (if applicable)
    - source
    - volume (if applicable)
    - issue (if applicable)
    - fpage (if applicable)
    - lpage (if applicable)
    - elocation-id (if applicable) - a single page number instead of a range is interpreted as elocation-id
    - uri (if applicable)
    - if the author made a typo mistake and used dot instead of comma between source and volume, 
      this is handled by a more permissive regex.
        - Should be ", 93" not ". 93" 
          ```<ref>Yarnell, K.S., Pollak, K.I., Østbye, T., & Krause, K.M. (2003). Primary care: Is there enough 
          time for prevention? <italic>American Journal of Public Health. 93</italic>(4), 635-641. 
          <uri>http://dx.doi.org/10.2105/AJPH.93.4.635</uri></ref>```

### Grouping, sectioning and parsing
- the body contents of the document is properly sectioned using sec/title elements based on the outline level on the headings
- citations in the text are identified by regex pattern matching and marked up as xref elements: ```<xref ref-type="bibr" rid="{autogenerated id}">...</xref>```
- when the citation is an et al. type reference, the name and year is compared to references already 
  tagged as element-citation in article/back/ref-list/ref. If there is one and only one match in the ref-list
  for this combination, then the id of that ref is copied over 
  to the rid-attribute of the et al. reference xref element.

## Todo

### Documentation/samples
- Add a couple sample documents with automatic tagging results from odf2jats
- Make a video with the workflow involved

### Unit testing/bugfixing
- implement unit testing to make it possible to improve the parsing of referenes in the reference list and the text

### XProc pipeline
- look into parameters. If text in the headers or footers is important, that is located in styles.xml.
    - http://www.data2type.de/en/xml-xslt-xslfo/xproc/xproc-introduction/typical-application-scenarios/
    - https://community.emc.com/docs/DOC-17045
- how do you send styles.xml to a p:xslt in it's parameter port.
    - do you need to use the parameter port to the pipeline
    - or can you calculate the file path and replace content.xml with styles.xml?

### Improve ref-list autotagging

When marking up electronic journal type references with elocation instead of page(s)
there are two options for formatting elocation id in lieu of an explicit construct in either of:
- The Publication Manual of the American Psychological Association
- The APA Style Guide to Electronic References, or on the APA Style Blog

The following options are:

- Option 1: as a page number instead of the page range. (This is the option that has been adopted).
    - Option 1: Leigh, J. P., Tancredi, D. J., & Kravitz, R. L. (2009). Physician career satisfaction within specialties. BMC Health Services Research, 9, 166. http://dx.doi.org/10.1186/1472-6963-9-166
- Option 2: insert the word "Article" before it.
    - Option 2: Leigh, J. P., Tancredi, D. J., & Kravitz, R. L. (2009). Physician career satisfaction within specialties. BMC Health Services Research, 9, Article 166. http://dx.doi.org/10.1186/1472-6963-9-166
    
Refs starting with following fail, but maybe this is acceptable because it is difficult to mark up using element-citation:

- NICE. (2012).
- WHO. (2000).
- Institute of Medicine. (2001).

### Tables
Table labels/titles/captions are now handled better. If they are styled with a 
special paragraph style do identify the content as being table label, table title or table caption

In libreOffice when creating a table, there is an option to create n header rows, and if one selects to repeat n headers on 
following pages, then a row is inserted in the table.

If this is not done, it is not possible to edit a table and make the first row a header row.

However, one can style the content of a whole row with the 'TableHeader style'. This will generate ```<td><p style="TableHeader">...</p></td>```.
This easily enables renaming of td to th elements in XProc, and this has been done.

Then, if the first row(s) only contain th-cells, they should be wrapped in ```<thead>...</thead>``` element. And the consequtive rows 
should be wrapped in ```<tbody>...</tbody>``` element. **This has not yet been implemented.**

The reason for doing this is accessibility concerns.

### Citations

Citations in the text that only have year within the parens, have **rid** attributes that misses capital letters from author's surname. 

- extract relevant capital letters from the text node directly before the xref-element?
- leave it as is and let the person doing the conversion manually fix those **rid** attributes?

*Edit: this is now handled automatically for et al. references where there is a match in the reference list but not for other references.*

### Lists

- Lists in the back section inside a table haven't got a list style type. This needs to be investigated.
- Lists in the back section inside a table get an undesireable style: ```<p style="List_20_Paragraph">...</p>```

### Automatic correction/error handling
In some cases it is obvious how to correct typing mistakes. This can be done automatically with regex,
but then a ```<xsl:message>...</xsl:message>``` should be generated about what was fixed. This 
will end up in the err.log so that corrections will not go unnoticed, and can be reported back
to the authors/editors.

Some tests should be made to check for and report common problems.

### Adjacent bold, italic elements of the same type with whitespace-only nodes between.
Sometimes the software for writing documents will insert adjacent bold or italic element
in the same word, depending on how the user edits the text. 
These should be merged, but maybe the white-space between can be significant, so this needs some care.

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
