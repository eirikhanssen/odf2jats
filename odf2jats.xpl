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
        <p:document href="source/odf-nylenna/content.xml"/>
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

    <p:rename match="p[preceding-sibling::h1='References']" new-name="ref"/>

    <p:delete match="h1[.='References']"/>

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

    <!-- Attempt to auto-tag citations in the running text -->
    <p:xslt name="textRefParsing" version="2.0">
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