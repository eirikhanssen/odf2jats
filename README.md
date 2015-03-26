# odf2jats
Developing an automatic tagging solution to produce **JATS XML** output from manuscripts in **Open Document Format** (.odt files).

## Open Document Format
Open Document Format is a free ISO-standardized format for documents (.odt file extension), spreadsheets (.ods) presentations and more.
ODF is supported by many programs and used as a native format by the free LibreOffice suite and OpenOffice.org.

## Project goals
To simplify and automate the conversion/tagging/marking up of scientific manuscripts 
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

## Related projects
The JATS XML file that this project aims to autogenerate is to be used with the jats2epub tool.
I am also working on a solution for automatically tagging Office Open XML documents.

- https://github.com/eirikhanssen/ooxml2jats - automatic tagging using Office Open XML format as a base
- https://github.com/eirikhanssen/jats2epub - generation of HTML fulltext, .epub and optionally .mobi formats from JATS XML source


## How to contribute

If you're interested in this project you can
- fork this project and issue a pull request
- send me a message
