<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns="http://www.tei-c.org/ns/1.0" 
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all">
    
    <!-- =================================================================================
         XSL to create a TEI Corpus file from the individual XML files in input/xml. 
         
         v.1 Created for Digital Humanities 2013 at the University of Nebraska-Lincoln by Karin Dalziel
         
         All selections are very literal, which may work or not depending on your TEI.
         Change as necessary
         
         ================================================================================= -->
    
    <xsl:output indent="yes"/>
    
    <!-- This is a wildly inefficient but convienent way to select documents -->
    <!-- <xsl:variable name="files" select="collection('../../input/xml?recurse=yes;select=*.xml')"/> -->
    <xsl:variable name="files" select="collection('../input/files?select=*.xml')"/><!-- DH2022 mod -->
    
    <!-- =================================================================================
         Main Document Structure
         ================================================================================= -->
    
    <xsl:template match="/">

        <teiCorpus xml:id="Book_Corpus">
            
            <xsl:call-template name="TEICorpusHeader"/>
            
            <!-- Begin repeating corpus info -->

            <!-- Introductory Materials -->
            <xsl:for-each select="$files[normalize-space(//keywords[@n='category']) = 'Intro']">
                <xsl:sort select="normalize-space(/TEI/@xml:id)"/>
                    <xsl:variable name="id"><xsl:value-of select="/TEI/@xml:id"/></xsl:variable>
                    <TEI n="{$id}">
                        <xsl:for-each select="/TEI/teiHeader[1]">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:for-each>
                        <xsl:copy-of select="/TEI/text"/>
                    </TEI>
            </xsl:for-each>
            
            <!-- List of Reviewers -->
            <xsl:for-each select="$files[normalize-space(//keywords[@n='category']) = 'Reviewers']">
                <xsl:sort select="normalize-space(/TEI/@xml:id)"/>
                    <!-- <xsl:variable name="id"><xsl:value-of select="/TEI/@xml:id"/></xsl:variable> -->
                    <xsl:variable name="id"><xsl:value-of select="concat(normalize-space(//keywords[@n='category']), '-', position())"/></xsl:variable><!-- DH2022 mod -->
                    <TEI n="{$id}">
                        <xsl:for-each select="/TEI/teiHeader[1]">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:for-each>
                        <xsl:copy-of select="/TEI/text"/>
                    </TEI>
                
            </xsl:for-each>
            
            <!-- Plenary Sessions -->
            <xsl:for-each select="$files[normalize-space(//keywords[@n='category']) = 'Plenary']">
                <!-- <xsl:sort select="normalize-space(/teiCorpus/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/name[1])"/> -->
                <xsl:sort select="replace(normalize-unicode(concat(
                    /teiCorpus/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/persName[1]/surname/(@key | text())[1],
                    /teiCorpus/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/persName[1]/forename/(@key | text())[1]
                ), 'NFD'), '[^a-zA-Z0-9]', '')"/><!-- DH2022 mod -->
                    <!-- <xsl:variable name="id"><xsl:value-of select="/TEI/@xml:id"/></xsl:variable> -->
                    <xsl:variable name="id"><xsl:value-of select="concat(normalize-space(//keywords[@n='category']), '-', position())"/></xsl:variable><!-- DH2022 mod -->
                    <TEI n="{$id}">
                        <xsl:for-each select="/TEI/teiHeader[1]">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:for-each>
                        <xsl:copy-of select="/TEI/text"/>
                    </TEI>
            </xsl:for-each> 
            
            
            <!-- Workshops -->
            <!-- <xsl:for-each select="$files[normalize-space(//keywords[@n='category']) = 'Workshops']"> -->
            <xsl:for-each select="$files[normalize-space(//keywords[@n='subcategory']) = 'Pre-Conference Workshop and Tutorial']"><!-- DH2022 mod -->
                <!-- <xsl:sort select="normalize-space(/TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/name[1])"/> -->
                <xsl:sort select="replace(normalize-unicode(concat(
                    /TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/persName[1]/surname/(@key | text())[1],
                    /TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/persName[1]/forename/(@key | text())[1]
                ), 'NFD'), '[^a-zA-Z0-9]', '')"/><!-- DH2022 mod -->
                    <!-- <xsl:variable name="id"><xsl:value-of select="/TEI/@xml:id"/></xsl:variable> -->
                    <xsl:variable name="id"><xsl:value-of select="concat('Workshop-', position())"/></xsl:variable><!-- DH2022 mod -->
                    <TEI n="{$id}">
                        <xsl:for-each select="/TEI/teiHeader[1]">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:for-each>
                        <!-- <xsl:copy-of select="/TEI/text"/> -->
                        <!-- DH2022: footnotes compatible -->
                        <text>
                            <xsl:apply-templates select="/TEI/text/body">
                                <xsl:with-param name="tei_id" select="$id" tunnel="yes"/>
                            </xsl:apply-templates>
                            <xsl:call-template name="backmatter">
                                <xsl:with-param name="tei_id" select="$id" tunnel="yes"/>
                            </xsl:call-template>
                        </text>
                    </TEI>
            </xsl:for-each> 
            
            
            <!-- Panels -->
            <!-- Different because many panels are corpus files -->
            <!-- <xsl:for-each select="$files[normalize-space(//keywords[@n='category']) = 'Panel']"> -->
            <xsl:for-each select="$files[normalize-space(//keywords[@n='subcategory']) = 'Panel']"><!-- DH2022 mod -->
                <!-- <xsl:sort select="normalize-space((//author)[1]/(name)[1])"/> -->
                <xsl:sort select="replace(normalize-unicode(concat(
                    //author[1]/persName[1]/surname/(@key | text())[1],
                    //author[1]/persName[1]/forename/(@key | text())[1]
                ), 'NFD'), '[^a-zA-Z0-9]', '')"/><!-- DH2022 mod -->
                    <!-- <xsl:variable name="id"><xsl:value-of select="/*/@xml:id"/></xsl:variable> -->
                    <xsl:variable name="id"><xsl:value-of select="concat(normalize-space(//keywords[@n='subcategory']), '-', position())"/></xsl:variable><!-- DH2022 mod -->
                    <TEI n="{$id}">
                        <xsl:choose>
                            <xsl:when test="/teiCorpus">
                                <xsl:for-each select="/teiCorpus/teiHeader[1]">
                                    <xsl:copy>
                                        <xsl:apply-templates select="@*|node()"/>
                                    </xsl:copy>
                                </xsl:for-each>
                                <text>
                                    <body>
                                        <xsl:for-each select="/teiCorpus/TEI">
                                            <div  type="{text/@type}">
                                                <head type="main"><xsl:value-of select="teiHeader/fileDesc/titleStmt/title"/></head>
                                                <xsl:if test="normalize-space(teiHeader/fileDesc/titleStmt/author[1])">
                                                    <head type="author">
                                                        <xsl:for-each select="teiHeader/fileDesc/titleStmt/author">
                                                            <xsl:if test="position() &gt; 1"><xsl:text> | </xsl:text></xsl:if>
                                                            <!-- <xsl:value-of select="name"/> -->
                                                            <xsl:value-of select="persName"/><!-- DH2022 mod -->
                                                        </xsl:for-each>
                                                    </head>
                                                </xsl:if>
                                                <xsl:copy-of select="text/body/div/node()"/>
                                                <xsl:if test="//back">
                                                    <div type="back">
                                                        <xsl:copy-of select="text/back/node()"/>
                                                    </div>
                                                </xsl:if>
                                                
                                            </div>
                                        </xsl:for-each>
                                    </body>
                                </text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="/TEI/teiHeader[1]">
                                    <xsl:copy>
                                        <xsl:apply-templates select="@*|node()"/>
                                    </xsl:copy>
                                </xsl:for-each>
                                <text>
                                    <body>
                                        <xsl:for-each select="/TEI">
                                            <div  type="{text/@type}">
                                                <!-- <head type="main"><xsl:value-of select="teiHeader/fileDesc/titleStmt/title"/></head> --><!-- DH2022 mod -->
                                                <xsl:if test="normalize-space(teiHeader/fileDesc/titleStmt/author[1])">
                                                </xsl:if>
                                                <!-- <xsl:copy-of select="text/body/div/node()"/> -->
                                                <!-- DH2022: accept div-less formats -->
                                                <xsl:apply-templates select="text/body/div/node()|text/body/p|text/body/head">
                                                    <xsl:with-param name="tei_id" select="$id" tunnel="yes"/>
                                                </xsl:apply-templates>
                                                
                                                <xsl:if test="//back">
                                                    <div type="back">
                                                        <xsl:copy-of select="text/back/node()"/>
                                                        <!-- DH2022: footnotes compatible -->
                                                        <xsl:call-template name="back_notes">
                                                            <xsl:with-param name="tei_id" select="$id" tunnel="yes"/>
                                                        </xsl:call-template>
                                                    </div>
                                                </xsl:if>
                                            </div>
                                        </xsl:for-each>
                                    </body>
                                </text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </TEI>
            </xsl:for-each>
            
            
            <!-- Papers -->
            
            <!-- DH2022: divided into long and short presentations -->
            <!-- <xsl:for-each select="$files[normalize-space(//keywords[@n='category']) = 'Paper']"> -->
            <xsl:for-each select="$files[normalize-space(//keywords[@n='subcategory']) = 'Long Presentation']"><!-- DH2022 mod -->
                <!-- <xsl:sort select="normalize-space(/TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/name[1])"/> -->
                <xsl:sort select="replace(normalize-unicode(concat(
                    /TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/persName[1]/surname/(@key | text())[1],
                    /TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/persName[1]/forename/(@key | text())[1]
                ), 'NFD'), '[^a-zA-Z0-9]', '')"/><!-- DH2022 mod -->
                    <!-- <xsl:variable name="id"><xsl:value-of select="/TEI/@xml:id"/></xsl:variable> -->
                    <xsl:variable name="id"><xsl:value-of select="concat('Long-', position())"/></xsl:variable><!-- DH2022 mod -->
                    <TEI n="{$id}">
                        <xsl:for-each select="/TEI/teiHeader[1]">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:for-each>
                        <!-- <xsl:copy-of select="/TEI/text"/> -->
                        <!-- DH2022: footnotes compatible -->
                        <text>
                            <xsl:apply-templates select="/TEI/text/body">
                                <xsl:with-param name="tei_id" select="$id" tunnel="yes"/>
                            </xsl:apply-templates>
                            <xsl:call-template name="backmatter">
                                <xsl:with-param name="tei_id" select="$id" tunnel="yes"/>
                            </xsl:call-template>
                        </text>
                    </TEI>
            </xsl:for-each>

            <!-- <xsl:for-each select="$files[normalize-space(//keywords[@n='category']) = 'Paper']"> -->
            <xsl:for-each select="$files[normalize-space(//keywords[@n='subcategory']) = 'Short Presentation']"><!-- DH2022 mod -->
                <!-- <xsl:sort select="normalize-space(/TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/name[1])"/> -->
                <xsl:sort select="replace(normalize-unicode(concat(
                    /TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/persName[1]/surname/(@key | text())[1],
                    /TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/persName[1]/forename/(@key | text())[1]
                ), 'NFD'), '[^a-zA-Z0-9]', '')"/><!-- DH2022 mod -->
                    <!-- <xsl:variable name="id"><xsl:value-of select="/TEI/@xml:id"/></xsl:variable> -->
                    <xsl:variable name="id"><xsl:value-of select="concat('Short-', position())"/></xsl:variable><!-- DH2022 mod -->
                    <TEI n="{$id}">
                        <xsl:for-each select="/TEI/teiHeader[1]">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:for-each>
                        <!-- <xsl:copy-of select="/TEI/text"/> -->
                        <!-- DH2022: footnotes compatible -->
                        <text>
                            <xsl:apply-templates select="/TEI/text/body">
                                <xsl:with-param name="tei_id" select="$id" tunnel="yes"/>
                            </xsl:apply-templates>
                            <xsl:call-template name="backmatter">
                                <xsl:with-param name="tei_id" select="$id" tunnel="yes"/>
                            </xsl:call-template>
                        </text>
                    </TEI>
            </xsl:for-each> 
            
            <!-- Posters -->
            
            <!-- <xsl:for-each select="$files[normalize-space(//keywords[@n='category']) = 'Poster']"> -->
            <xsl:for-each select="$files[normalize-space(//keywords[@n='subcategory']) = 'Electronic Poster']"><!-- DH2022 mod -->
                <!-- <xsl:sort select="normalize-space(/TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/name[1])"/> -->
                <xsl:sort select="replace(normalize-unicode(concat(
                    /TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/persName[1]/surname/(@key | text())[1],
                    /TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author[1]/persName[1]/forename/(@key | text())[1]
                ), 'NFD'), '[^a-zA-Z0-9]', '')"/><!-- DH2022 mod -->
                    <!-- <xsl:variable name="id"><xsl:value-of select="/TEI/@xml:id"/></xsl:variable> -->
                    <xsl:variable name="id"><xsl:value-of select="concat('Poster-', position())"/></xsl:variable><!-- DH2022 mod -->
                    <TEI n="{$id}">  
                        <xsl:for-each select="/TEI/teiHeader[1]">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:for-each>
                            <!-- <xsl:copy-of select="TEI/text"/> -->
                        <!-- DH2022: footnotes compatible -->
                        <text>
                            <xsl:apply-templates select="/TEI/text/body">
                                <xsl:with-param name="tei_id" select="$id" tunnel="yes"/>
                            </xsl:apply-templates>
                            <xsl:call-template name="backmatter">
                                <xsl:with-param name="tei_id" select="$id" tunnel="yes"/>
                            </xsl:call-template>
                        </text>
                    </TEI>
            </xsl:for-each> 

            <!-- End repeating corpus info -->
 
        </teiCorpus>
      
   
        
    </xsl:template>
    

    <!-- =================================================================================
         TEI Text template rules 
         ================================================================================= -->
    
    <xsl:template match="p">
        <xsl:element name="p">
            <xsl:if test="@rend"><xsl:attribute name="rend" select="@rend"/></xsl:if><!-- DH2022 mod -->
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="TEICorpusHeader">

            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Digital Humanities 2022 Combined Abstracts</title>
                        <author>
                        </author>
                    </titleStmt>
                    <publicationStmt>
                        <authority></authority>
                        <publisher>DH2022 Local Organizing Committee</publisher>
                        <distributor>
                            <name>DH2022 Local Organizing Committee</name>
                            <address>
<addrLine>7-3-1</addrLine>
<addrLine>Hongo, Bunkyo-ku</addrLine>
<addrLine>Tokyo, 113-0033</addrLine>
<addrLine>dh2022-local{at}l.u-tokyo.ac.jp</addrLine>
</address>
                        </distributor>
                        <pubPlace>Tokyo, Japan</pubPlace> 
                        <address>
<addrLine>The University of Tokyo</addrLine>
<addrLine>Tokyo, 113-0033</addrLine>
</address>
                        <availability>
                            <p></p>
                        </availability>
                    </publicationStmt>
                    
                    <notesStmt><note></note></notesStmt>
                    
                    <sourceDesc>
                        <p>No source: created in electronic format.</p>
                    </sourceDesc>
                </fileDesc>
                
                <profileDesc>
                    <textClass>
                    </textClass>
                </profileDesc>
                
                <revisionDesc>
                    <change>
                        <date when="2022-07-26"></date>
                        <name>Wang Yifan</name>
                        <desc>First release</desc>
                    </change>
                    <change>
                        <date when="2022-07-24"></date>
                        <name>Wang Yifan</name>
                        <desc>Initial encoding</desc>
                    </change>
                </revisionDesc>
            </teiHeader>
    </xsl:template>
    
    
    
    <xsl:template match="author">
        <xsl:variable name="alt_id"><!-- DH2022 variable -->
            <xsl:value-of select="
                string-join(
                    tokenize(
                        substring-before(
                            tokenize(base-uri(), '/')[last()]
                            , '.'
                        )
                        , '_+'
                    )
                    , '_'
                )
            "/>
        </xsl:variable>
        <author>
            <xsl:attribute name="n">
                <xsl:value-of select="replace(name/surname,'[^a-zA-Z0-9]','')"/>
                <xsl:value-of select="replace(name/forename,'[^a-zA-Z0-9]','')"/>
                <xsl:value-of select="replace(normalize-unicode(persName/surname/(@key | text())[1], 'NFD'), '[^a-zA-Z0-9]', '')"/><!-- DH2022 mod -->
                <xsl:value-of select="replace(normalize-unicode(persName/forename/(@key | text())[1], 'NFD'), '[^a-zA-Z0-9]', '')"/><!-- DH2022 mod -->
                <xsl:choose>
                    <xsl:when test="/teiCorpus">
                        <xsl:value-of select="/teiCorpus/@xml:id"/>
                    </xsl:when>
                    <xsl:when test="/TEI">
                        <!-- <xsl:value-of select="/TEI/@xml:id"/> -->
                        <xsl:value-of select="$alt_id"/><!-- DH2022 mod -->
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <name>
                <xsl:attribute name="n">
                    <xsl:value-of select="replace(name/surname,'[^a-zA-Z0-9]','') "/>
                    <xsl:value-of select="replace(name/forename,'[^a-zA-Z0-9]','') "/>
                    <xsl:value-of select="replace(normalize-unicode(persName/surname/(@key | @nymRef | text())[1], 'NFD'), '[^a-zA-Z0-9]', '')"/><!-- DH2022 mod -->
                    <xsl:value-of select="replace(normalize-unicode(persName/forename/(@key | @nymRef | text())[1], 'NFD'), '[^a-zA-Z0-9]', '')"/><!-- DH2022 mod -->
                </xsl:attribute>
                <!-- <xsl:copy-of select="name/node()"/></name> -->
                <xsl:copy-of select="name/node()"/><xsl:copy-of select="persName/node()"/></name><!-- DH2022 mod -->
            <xsl:copy-of select="affiliation"/>
            <xsl:copy-of select="email"/>
    
        </author>
    </xsl:template>
    
    <xsl:template name="TEIHeader">
        <xsl:param name="title"/> 
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title><xsl:value-of select="$title"/></title>
                    </titleStmt>
                    <publicationStmt>
                    </publicationStmt>
                    
                    
                    <sourceDesc>
                        <p>No source: created in electronic format.</p>
                    </sourceDesc>
                </fileDesc>
                
                
            </teiHeader>
    </xsl:template>

    <!-- DH2022: reproducing notes block -->

    <xsl:template name="backmatter">
        <xsl:if test="/TEI/text/back or /TEI/text/body//note[@place='foot' or @place='end']">
            <back>
                <xsl:copy-of select="/TEI/text/back/node()"/>
                <xsl:call-template name="back_notes"/>
            </back>
        </xsl:if>
    </xsl:template>

    <xsl:template name="back_notes">
        <xsl:if test="/TEI/text/body//note[@place='foot' or @place='end']">
            <div type="notes">
                <xsl:apply-templates select="/TEI/text/body//note[@place='foot' or @place='end']" mode="notes"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="note[@place='foot' or @place='end']">
        <xsl:param name="tei_id" tunnel="yes"/>
        <ref target="{concat($tei_id, '-', @xml:id)}" n="{@n}" rend="{@place}"/>
    </xsl:template>

    <xsl:template match="note[@place='foot' or @place='end']" mode="notes">
        <xsl:param name="tei_id" tunnel="yes"/>
        <note xml:id="{concat($tei_id, '-', @xml:id)}" n="{@n}" rend="{@place}">
            <xsl:choose>
                <xsl:when test="not(p)">
                    <p><xsl:apply-templates/></p>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="node()[not(normalize-space(.)='ENDNOTES')]"/><!-- ad-hoc condition to ignore unneeded headings -->
                </xsl:otherwise>
            </xsl:choose>
        </note>
    </xsl:template>
    
</xsl:stylesheet>
