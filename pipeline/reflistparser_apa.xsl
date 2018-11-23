<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:o2j="https://github.com/eirikhanssen/odf2jats"
  exclude-result-prefixes="xs xlink o2j">
  <xsl:import href="odf2jats-functions.xsl"/>
  <xsl:output method="xml" indent="yes"/>

  <!-- 'debug=on|true|1' can be specified as a paramenter during runtime, and then debug output will be shown -->
  <xsl:param name="debug" as="xs:string">off</xsl:param>

  <xsl:variable name="debugMode" as="xs:boolean">
    <!-- decide if debugMode is on or off and assign true or false boolean to $debugMode variable -->
    <!-- case insensitive match using the "i" flag -->
    <xsl:value-of select="matches($debug , '^(on|true|1|yes)$' , 'i')"/>
  </xsl:variable>

  <xsl:template match="ref-list">
    <ref-list>
      <xsl:for-each select="ref">
        <xsl:call-template name="ref"/> 
      </xsl:for-each>
    </ref-list>
  </xsl:template>
  
  <xsl:template name="ref">
    <ref>
      <xsl:attribute name="id" select="o2j:generate_id_for_mixed_citation(.)"/>
      <mixed-citation><xsl:apply-templates/></mixed-citation>
    </ref>
  </xsl:template>

  <xsl:template match="ext-link">
    <uri><xsl:value-of select="./@xlink:href"/></uri>
  </xsl:template>

  <xsl:template match="uri">
    <uri><xsl:value-of select="."/></uri>
  </xsl:template>

  <xsl:template match="italic" mode="comment">
    <xsl:text>&lt;italic></xsl:text><xsl:apply-templates/><xsl:text>&lt;/italic></xsl:text>
  </xsl:template>

  <xsl:template match="uri" mode="comment">
    <xsl:text>&lt;uri></xsl:text><xsl:apply-templates/><xsl:text>&lt;/uri></xsl:text>
  </xsl:template>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>