<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0"
    name="odf2jats"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    exclude-inline-prefixes="c p">

    <!-- take input document from parameter -->
    <p:input port="source"/>
    
    <p:input port="documentStylesPath" kind="parameter"/>
        
    <p:output port="result"/>

    <p:serialization port="result" indent="true"/>

    <p:xslt name="flat_odf_xml_extract" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="flat_odf_xml_extract.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:pipe step="odf2jats" port="documentStylesPath"/>
        </p:input>
    </p:xslt>

    <!-- correct and report common typing mistakes -->
    <p:xslt name="autocorrections" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="autocorrections.xsl"/>
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

    <p:delete match="h2[.='References']"/>

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

    <p:xslt name="fix-table-captions-and-labels" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="table-captions-and-labels.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <!-- if td has a child p with @style="TableHeaderStyle", then rename to th element -->
    <p:rename name="td_to_th_if_TableHeader" match="td[p[@style='TableHeader']]" new-name="th"/>
    <!-- remove @style from p[@style="TableHeader"] -->
    <p:delete match="p/@style[.='TableHeader']"/>
    
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

    <!-- insert a comment to notify that there are authors that haven't been supplied in the manuscript. -->
    <p:insert match="/article/back/ref-list/ref/element-citation/person-group[@person-group-type='author']/name[matches(surname , '^…')]" position="before">
        <p:input port="insertion">
            <!-- I just want to insert a comment, but if I don't have an element here, the processor complains that p:inline is incomplete -->
            <p:inline><!-- Article has more authors than can be listed in APA style, some are missing here. --><commentDummy/></p:inline>
        </p:input>
    </p:insert>

    <p:delete match="//commentDummy"/>

    <!-- Delete ellipsis from surname of author -->
    <p:string-replace 
        match="/article/back/ref-list/ref/element-citation/person-group[@person-group-type='author']/name/surname/text()[matches(. , '^\s*…\s*.*?$')]" 
        replace="replace(. , '^\s*…\s*(.*?)$','$1')"/>

    <!-- Attempt to auto-tag citations in the running text -->
    <p:xslt name="reftextparser_et_al_outside_parens" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="reftextparser_apa_et_al_outside_parens.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <p:xslt name="reftextparser" version="2.0">
        <p:input port="source"/>
        <p:input port="stylesheet">
            <p:document href="reftextparser_apa.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>

    <!-- Delete unneeded style attributes from some p elements -->
    <!--<p:delete match="p/@style"/>-->

    <p:identity/>

</p:declare-step>