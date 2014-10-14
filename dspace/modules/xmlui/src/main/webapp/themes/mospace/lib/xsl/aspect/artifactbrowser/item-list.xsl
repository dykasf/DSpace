<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->
<!--
    Rendering of a list of items (e.g. in a search or
    browse results page)

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util confman">

    <xsl:output indent="yes"/>

    <!--these templates are modfied to support the 2 different item list views that
    can be configured with the property 'xmlui.theme.mirage.item-list.emphasis' in dspace.cfg-->

    <xsl:template name="itemSummaryList-DIM">
        <xsl:variable name="itemWithdrawn" select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/@withdrawn" />

        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="$itemWithdrawn">
                    <xsl:value-of select="@OBJEDIT"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@OBJID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="emphasis" select="confman:getProperty('xmlui.theme.mirage.item-list.emphasis')"/>
        <xsl:choose>
            <xsl:when test="'file' = $emphasis">


                <div class="item-wrapper clearfix">
                    <xsl:apply-templates select="./mets:fileSec" mode="artifact-preview"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
                    <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                         mode="itemSummaryList-DIM-file"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                     mode="itemSummaryList-DIM-metadata"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--handles the rendering of a single item in a list in file mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-file">
        <xsl:param name="href"/>
        <xsl:variable name="metadataWidth" select="675 - $thumbnail.maxwidth - 30"/>
        <div class="item-metadata" style="width: {$metadataWidth}px;">
            <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.title</i18n:text><xsl:text>:</xsl:text></span>
            <span class="content" style="width: {$metadataWidth - 110}px;">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title' and descendant::text()]">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </span>
            <span class="Z3988">
                <xsl:attribute name="title">
                    <xsl:call-template name="renderCOinS"/>
                </xsl:attribute>
                &#xFEFF; <!-- non-breaking space to force separating the end tag -->
            </span>
            <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.author</i18n:text><xsl:text>:</xsl:text></span>
            <span class="content" style="width: {$metadataWidth - 110}px;">
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <span>
                                <xsl:if test="@authority">
                                    <xsl:attribute name="class">
                                        <xsl:text>ds-dc_contributor_author-authority</xsl:text>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='creator']">
                        <xsl:for-each select="dim:field[@element='creator']">
                            <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='contributor']">
                        <xsl:for-each select="dim:field[@element='contributor']">
                            <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
            <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
                <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.date</i18n:text><xsl:text>:</xsl:text></span>
                <span class="content" style="width: {$metadataWidth - 110}px;">
                    <xsl:value-of
                            select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                </span>
            </xsl:if>
        </div>
    </xsl:template>

    <!--handles the rendering of a single item in a list in metadata mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-metadata">
        <xsl:param name="href"/>
        <div class="artifact-description">
            <div class="artifact-title">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title' and descendant::text()]">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF; <!-- non-breaking space to force separating the end tag -->
                </span>
            </div>
            <div class="artifact-info">
                <span class="author">
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                <span>
                                  <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                  </xsl:if>
                                  <xsl:copy-of select="node()"/>
                                </span>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='creator']">
                            <xsl:for-each select="dim:field[@element='creator']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor']">
                            <xsl:for-each select="dim:field[@element='contributor']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
                <xsl:text> </xsl:text>
                <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
	                <span class="publisher-date">
	                    <xsl:text>(</xsl:text>
	                    <xsl:if test="dim:field[@element='publisher']">
	                        <span class="publisher">
	                            <xsl:copy-of select="dim:field[@element='publisher']/node()"/>
	                        </span>
	                        <xsl:text>, </xsl:text>
	                    </xsl:if>
	                    <span class="date">
	                        <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
	                    </span>
	                    <xsl:text>)</xsl:text>
	                </span>
                </xsl:if>
            </div>
            <xsl:if test="dim:field[@element = 'description' and @qualifier='abstract']">
                <xsl:variable name="abstract" select="dim:field[@element = 'description' and @qualifier='abstract']/node()"/>
                <div class="artifact-abstract">
                    <xsl:value-of select="util:shortenString($abstract, 220, 10)"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template name="itemDetailList-DIM">
        <xsl:call-template name="itemSummaryList-DIM"/>
    </xsl:template>


    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <xsl:param name="href"/>
        <div class="thumbnail-wrapper" style="width: {$thumbnail.maxwidth}px;">
            <div class="artifact-preview">
                <a class="image-link" href="{$href}">
                    <xsl:choose>
                        <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']">
                            <img alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of
                                            select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                </xsl:attribute>
                            </img>
                        </xsl:when>
                        <xsl:when test="@MIMETYPE = 'application/pdf'">
                            <img alt="[PDF]" src="{concat($theme-path, '/images/mimes/pdf.png')}" style="height: 48px;" width="48" height="48" title="PDF file"/>
                        </xsl:when>
                        <xsl:when test="starts-with(@MIMETYPE, 'audio/')">
                            <img alt="[Audio]" src="{concat($theme-path, '/images/mimes/audio.png')}" style="height: 48px;" width="48" height="48" title="Audio file"/>
                        </xsl:when>
                        <xsl:when test="starts-with(@MIMETYPE, 'video/')">
                            <img alt="[Video]" src="{concat($theme-path, '/images/mimes/video.png')}" style="height: 48px;" width="48" height="48" title="Video file"/>
                        </xsl:when>
                        <xsl:when test="starts-with(@MIMETYPE, 'image/')">
                            <img alt="[Image]" src="{concat($theme-path, '/images/mimes/image.png')}" style="height: 48px;" width="48" height="48" title="Image file"/>
                        </xsl:when>
                        <xsl:when test="@MIMETYPE = 'application/vnd.ms-powerpoint' or @MIMETYPE = 'application/vnd.openxmlformats-officedocument.presentationml.presentation'">
                            <img alt="[PP]" src="{concat($theme-path, '/images/mimes/mspowerpoint.png')}" style="height: 48px;" width="48" height="48" title="MS Powerpoint file"/>
                        </xsl:when>
                        <xsl:when test="@MIMETYPE = 'application/vnd.oasis.opendocument.presentation' or @MIMETYPE = 'application/vnd.sun.xml.impress' or @MIMETYPE = 'application/vnd.stardivision.impress'">
                            <img alt="[Presentation]" src="{concat($theme-path, '/images/mimes/oopresentation.png')}" style="height: 48px;" width="48" height="48" title="Presentation slide deck"/>
                        </xsl:when>
                        <xsl:when test="@MIMETYPE = 'application/msword' or @MIMETYPE = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'">
                            <img alt="[Word]" src="{concat($theme-path, '/images/mimes/msword.png')}" style="height: 48px;" width="48" height="48" title="MS Word file"/>
                        </xsl:when>
                        <xsl:when test="@MIMETYPE = 'application/vnd.oasis.opendocument.text' or @MIMETYPE = 'application/vnd.sun.xml.writer' or @MIMETYPE = 'application/vnd.stardivision.writer'">
                            <img alt="[Writer]" src="{concat($theme-path, '/images/mimes/ootext.png')}" style="height: 48px;" width="48" height="48" title="Word processor file"/>
                        </xsl:when>
                        <xsl:when test="@MIMETYPE = 'application/vnd.ms-excel' or @MIMETYPE = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'">
                            <img alt="[Excel]" src="{concat($theme-path, '/images/mimes/msexcel.png')}" style="height: 48px;" width="48" height="48" title="MS Excel file"/>
                        </xsl:when>
                        <xsl:when test="@MIMETYPE = 'application/vnd.oasis.opendocument.spreadsheet' or @MIMETYPE = 'application/vnd.sun.xml.calc' or @MIMETYPE = 'application/vnd.stardivision.calc'">
                            <img alt="[Spreadsheet]" src="{concat($theme-path, '/images/mimes/oospreadsheet.png')}" style="height: 48px;" width="48" height="48" title="Spreadsheet"/>
                        </xsl:when>
                        <xsl:when test="@MIMETYPE = 'application/x-iso9660-image'">
                            <img alt="[ISO]" src="{concat($theme-path, '/images/mimes/iso.png')}" style="height: 48px;" width="48" height="48" title="Disk image"/>
                        </xsl:when>
                        <xsl:when test="@MIMETYPE = 'application/zip'">
                            <img alt="[ZIP]" src="{concat($theme-path, '/images/mimes/archive.png')}" style="height: 48px;" width="48" height="48" title="ZIP archive"/>
                        </xsl:when>
                        <xsl:when test="@MIMETYPE = 'text/richtext'">
                            <img alt="[RTF]" src="{concat($theme-path, '/images/mimes/rtf.png')}" style="height: 48px;" width="48" height="48" title="RTF file"/>
                        </xsl:when>
                        <xsl:when test="@MIMETYPE = 'text/xml'">
                            <img alt="[XML]" src="{concat($theme-path, '/images/mimes/html.png')}" style="height: 48px;" width="48" height="48" title="XML file"/>
                        </xsl:when>
                        <xsl:when test="@MIMETYPE = 'text/html'">
                            <img alt="[HTML]" src="{concat($theme-path, '/images/mimes/html.png')}" style="height: 48px;" width="48" height="48" title="HTML file"/>
                        </xsl:when>
                        <xsl:when test="starts-with(@MIMETYPE, 'text/')">
                            <img alt="[Text]" src="{concat($theme-path, '/images/mimes/text.png')}" style="height: 48px;" width="48" height="48" title="Text file"/>
                        </xsl:when>
                   </xsl:choose>
                </a>
            </div>
        </div>
    </xsl:template>


</xsl:stylesheet>