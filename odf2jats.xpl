<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
    name="odf2jats"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    exclude-inline-prefixes="c p">

    <p:input port="source">
        <!--<p:document href="source/odf-testdoc/content.xml"/>-->
        <!--<p:document href="source/odf-nylenna/content.xml"/>-->
        <!--<p:document href="source/odf-crosson/content.xml"/>-->
        <!--<p:document href="source/odf-casalino_crosson/content.xml"/>-->
        <!--<p:document href="source/odf-exworthy/content.xml"/>-->
        <p:document href="source/odf-exworthy-refs/content.xml"/>
    </p:input>

    <p:output port="result"/>

    <p:serialization port="result" indent="true"/>

    <p:xslt name="flat_odf_xml_extract" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="flat_odf_xml_extract.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <p:xslt name="figures" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="figures.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="generate-figure-id" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="generate-figure-id.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    

    <p:xslt name="article-history" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="article-history.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <p:rename match="p[preceding-sibling::h2='References']" new-name="ref"/>

    <p:delete match="h2[.='References']"/>

    <!-- delete empty p-elements -->
    <p:delete match="p[.='']"/>

    <p:xslt name="fix_keywords_and_abstract_first_stage" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="kwd_abstract.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <p:xslt name="group_to_front_body_back" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="group_to_front_body_back.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <!-- Delete fn elements in the body, but not if they belong to a table-wrap element -->
    <p:delete match="fn[ancestor::body][not(ancestor::table-wrap)]"/>

    <p:xslt name="group_sections_in_body" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="group_sections_in_body.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <p:rename match="h1|h2|h3|h4|h5|h6" new-name="title"/>

    <!-- Delete unneeded lvl attribute from sec elements -->
    <p:delete match="sec/@lvl"/>
    
    <p:xslt name="comma_surrounded_by_italic" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="comma_surrounded_by_italic.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="merge_adjacent_italic.xsl" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="merge_adjacent_italic.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="remove_doi_marker_immediately_before_tagged_doi_url" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="remove_doi_marker_immediately_before_tagged_doi_url.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <p:xslt name="tag_doi_refs_as_uri" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="tag_doi_refs_as_uri.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <p:xslt name="tag_loose_links_as_uri" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="tag_loose_links_as_uri.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <!-- autotagging of ref-list references -->
    <p:xslt name="reflistparser" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="reflistparser_apa.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <!-- Attempt to auto-tag citations in the running text -->
    <p:xslt name="reftextparser" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="reftextparser_apa.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <p:identity/>

</p:declare-step>