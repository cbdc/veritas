<resource schema="veritas">

  <meta name="title">VERITAS</meta>
  <meta name="description">
  The VERITAS spectra database.
  ---
  VERITAS-SVO.alpha version
  </meta>
  <meta name="creationDate">2017-05-05T10:10:10Z</meta>
  <meta name="subject">spectra</meta>
  <meta name="subject">high energy astrophysics</meta>
  <meta name="subject">gamma rays</meta>

  <meta name="creator.name">Carlos Brandt</meta>
  <meta name="facility">VERITAS</meta>

  <!-- <meta name="source">
    The MAGIC data center, http://magic.pic.es/
  </meta> -->
  <meta name="contentLevel">Research</meta>
  <meta name="type">Archive</meta>

  <meta name="coverage">
    <meta name="waveband">Gamma-ray</meta>
    <meta name="profile">AllSky ICRS</meta>
  </meta>


  <!-- =============== -->
  <!--  Table block    -->
  <!-- =============== -->

  <table id="main" onDisk="True" adql="True">
    <mixin
      fluxCalibration="ABSOLUTE"
      fluxUnit="ph / (m2 TeV s)"
      fluxUCD="phot.flux.density;em.freq"
      spectralUnit="TeV"
      spectralUCD="em.freq"
      > //ssap#hcd
    </mixin>
    <!-- <column name="ssa_reference"
            type="text"
            tablehead="Reference"/>
    <column name="ra"
            type="double precision"
            unit="deg" ucd="pos.eq.ra"
            tablehead="RA_J2000"
            verbLevel="20"
            description="Right Ascension"
            required="True"/>
    <column name="dec"
            type="double precision"
            unit="deg" ucd="pos.eq.dec"
            tablehead="DEC_J2000"
            verbLevel="20"
            description="Declination"
            required="True"/> -->
  </table>


  <table id="spectrum">
    <mixin
      ssaTable="main"
      fluxDescription="Absolute Flux"
      spectralDescription="Frequency"
      > //ssap#sdm-instance
    </mixin>
    <column name="dnde_errp"
            ucd="stat.error;phot.flux.density;em.freq">
      <values nullLiteral="-999"/>
    </column>
    <column name="dnde_errn"
            ucd="stat.error;phot.flux.density;em.freq">
      <values nullLiteral="-999"/>
    </column>
    <!-- <column name="ssa_timeExt">
      <values nullLiteral="-999"/>
    </column> -->
  </table>


  <!-- =============== -->
  <!--  Data block     -->
  <!-- =============== -->

  <data id="import">

<!--
    <property name="previewDir">previews</property>
-->
    <sources pattern='data/*.fits' recurse="False" />

    <fitsProdGrammar hdu="1" qnd="False">
      <rowfilter procDef="//products#define">
        <bind name="table">"\schema.data"</bind>
<!--
        <bind name="preview">\standardPreviewPath</bind>
        <bind name="preview_mime">"image/png"</bind>
-->
      </rowfilter>
<!--
      <rowfilter name="addSDM">
    <code>
     yield row
     baseAccref = os.path.splitext(row["prodtblPath"])[0]
     row["prodtblAccref"] = baseAccref+".vot"
     row["prodtblPath"] = row["prodtblAccref"]
     row["prodtblMime"] = "application/x-votable+xml"
     yield row
    </code>
   </rowfilter>
-->
    </fitsProdGrammar>

    <make table="main">
      <rowmaker idmaps="*">
        <!-- <map key="dec">@DEC</map>
        <map key="ra">@RA</map>
        <apply name="fixMissingTelescop">
          <code>
            try:
              @instrument = @TELESCOP
            except:
              @instrument = 'MAGIC'
            try:
              @specstart = @EMIN
            except:
              @specstart = 50
            try:
              @specend = @EMAX
            except:
              @specend = 1000
            try:
              @timeext = @TOBS
            except:
              @timeext = None
            if @EBL_CORR == 'TRUE':
              @ebl_corrected = 1
            else:
              @ebl_corrected = 0
          </code>
        </apply> -->
        <apply procDef="//ssap#setMeta" name="setMeta">
          <bind name="pubDID">\standardPubDID</bind>
          <!-- <bind name="dstitle">@OBJECT+'_'+@EXTNAME+'_'+@DATE_OBS</bind> -->
          <bind name="targname">@OBJECT</bind>
          <!-- <bind name="alpha">@RA</bind>
          <bind name="delta">@DEC</bind>
          <bind name="dateObs">@DATE_OBS</bind> -->
          <bind name="bandpass">"Gamma-ray"</bind>
          <!-- <bind name="specstart">@specstart</bind>
          <bind name="specend">@specend</bind>
          <bind name="timeExt">@timeext</bind> -->
          <bind name="length">@NAXIS2</bind>
        </apply>
        <apply procDef="//ssap#setMixcMeta" name="setMixcMeta">
          <!-- <bind name="instrument">@instrument</bind>
          <bind name="creator">@AUTHOR</bind>
          <bind name="reference">@REFPAPER</bind> -->
        </apply>
      </rowmaker>
    </make>

  </data>


  <data id="build_sdm_data" auto="False">

    <embeddedGrammar>
      <iterator>
        <setup>
          <code>
            from gavo.utils import pyfits
            from gavo.protocols import products
          </code>
        </setup>
        <code>
          fitsPath = products.RAccref.fromString(
          self.sourceToken["accref"]).localpath
          hdu = pyfits.open(fitsPath)[1]
          for row in enumerate(hdu.data):
            yield {"spectral": row[1][0], "flux": row[1][2]}
        </code>
      </iterator>
    </embeddedGrammar>

    <make table="spectrum">
      <parmaker>
        <apply procDef="//ssap#feedSSAToSDM"/>
      </parmaker>
    </make>

  </data>


  <!-- =============== -->
  <!--  Service block  -->
  <!-- =============== -->

  <service id="web" defaultRenderer="form">
    <meta name="shortName">Veritas Web</meta>
    <meta name="title">VERITAS Spectra Web Interface</meta>

    <publish render="form" sets="local"/>

    <dbCore queriedTable="main">
      <condDesc buildFrom="ssa_location"/>
      <condDesc buildFrom="ssa_dateObs"/>
    </dbCore>

    <outputTable>
      <!-- <autoCols>
        ssa_targname, accref, mime, ssa_dateObs, ssa_reference,
        ssa_specstart, ssa_specend, ssa_timeExt, ssa_instrument, ssa_length
      </autoCols> -->
      <FEED source="//ssap#atomicCoords"/>
      <!-- <outputField original="ssa_specstart" displayHint="displayUnit=m"/>
      <outputField original="ssa_specend" displayHint="displayUnit=m"/>
      <outputField original="ssa_reference" select="array[ssa_reference,reference_doi]">
        <formatter><![CDATA[
          lbl = data[0]
          url = data[1]
          yield T.a(href="%s"%url , target="_blank")["%s"%lbl]
        ]]></formatter>
      </outputField>
      <outputField original="asdc_link" select="array[ra_j2000,dec_j2000]">
        <formatter><![CDATA[
          _ra = data[0]
          _dec = data[1]
          url = 'http://tools.asdc.asi.it/SED/sed.jsp?&ra=%s&dec=%s' % (str(_ra),str(_dec))
          yield T.a(href="%s"%url , target="_blank")["ASDC/SED tool"]
        ]]></formatter>
      </outputField> -->
    </outputTable>

  </service>

  <!-- <service id="ssa" allowed="ssap.xml">
    <meta name="shortName">Veritas SSAP</meta>
    <meta name="title">VERITAS Spectra SSAP Interface</meta>
    <meta name="ssap.dataSource">pointed</meta>
    <meta name="ssap.creationType">archival</meta>
    <meta name="ssap.testQuery">MAXREC=1</meta>

    <publish render="ssap.xml" sets="ivo_managed"/>

    <ssapCore queriedTable="main">
      <FEED source="//ssap#hcd_condDescs"/>   <!-- Do we have an option for ssap#mixc? Make sense?! -->
    </ssapCore>

  </service> -->

</resource>
