BSDC-VERITAS
############

This document presents what came to be the `version 3` of
VERITAS-BSDC data format.
The data format present below is the result of an interactive process
between VERITAS and BSDC trying to accomplish easieness of use and
standards adopted in the gamma-ray community.
Snapshots of this process can be seen in the previous alike documents:

* data_formatting-v1.rst
* data_formatting-v2.rst


Data format:
============

After the last interaction, [v2]_, some modifications over metadata
keywords were applied to accomplish the processing data files need
to follow.

.. [v2] see `data_formatting-v2.rst`

The modifications proposed here were motivated mainly to keep metadata
as clear and clean as possible; some changes were motivated by the
processing of data itself -- for the data is transformed to FITS before
being published.

After the example below, the data format structure -- without content --
is proposed for a better understand of what is essencial and what is
not in such version of the format.


Example:
--------

The following example is the same (data file) used in the previous
document, the `Mrk421_2008_highA` observation file::

  # %ECSV 0.9
  # ---
  # meta: !!omap
  # - OBJECT: Mrk 421
  #
  # - DESCRIBE:
  #    Spectral points for multiwavelength campaign;
  #    Observations taken between 2008 January 01 and 2008 June 05;
  #    Flux sensitivity 0.8e-10 < flux(E>1TeV) < 1.1e-10
  #
  # - MJD:
  #    START: 54502.46971 # unit=day
  #    END: 54622.18955   # unit=day
  #
  # - ARTICLE:
  #    label: Ap.J. 738, 25 (2011)
  #    url: http://iopscience.iop.org/0004-637X/738/1/25/
  #    arxiv: http://arxiv.org/abs/1106.1210
  #    ads: http://adsabs.harvard.edu/abs/2011ApJ...738...25A
  #
  # - COMMENTS:
  #    Name: Mrk421_2008_highA
  #    Tag: highA
  #    Redshift: 0.031
  #    LiveTime: 1.4  # unit=hour
  #    Significance: 73.0
  #
  # - SED_TYPE: diff_flux_points
  #
  # datatype:
  # - name: e_ref
  #   unit: TeV
  #   datatype: float64
  # - name: dnde
  #   unit: ph / (m2 TeV s)
  #   datatype: float64
  # - name: dnde_errn
  #   unit: ph / (m2 TeV s)
  #   datatype: float64
  # - name: dnde_errp
  #   unit: ph / (m2 TeV s)
  #   datatype: float64
  #
  e_ref dnde       dnde_errn  dnde_errp
  0.275 1.702E-005 3.295E-006 3.295E-006
  0.340 1.289E-005 1.106E-006 1.106E-006
  0.420 8.821E-006 6.072E-007 6.072E-007
  0.519 5.777E-006 3.697E-007 3.697E-007
  0.642 3.509E-006 2.351E-007 2.351E-007
  0.793 2.151E-006 1.525E-007 1.525E-007
  0.980 1.302E-006 1.024E-007 1.024E-007
  1.212 6.273E-007 6.117E-008 6.117E-008
  1.498 3.310E-007 3.853E-008 3.853E-008
  1.851 1.661E-007 2.401E-008 2.401E-008
  2.288 1.124E-007 1.732E-008 1.732E-008
  2.828 6.158E-008 1.138E-008 1.138E-008
  3.496 3.347E-008 7.427E-009 7.427E-009
  4.321 1.160E-008 4.031E-009 4.031E-009
  5.342 5.230E-009 2.371E-009 2.371E-009


The format:
-----------

In the following, consider *value* between `< >` as the value to be
substituted. Notice the indentation, it is essencial for parsing the
information correctly.

::

  # %ECSV 0.9
  # ---
  # meta: !!omap
  # - OBJECT:   <name of the object>
  #
  # - DESCRIBE:
  #    <multiple line description of the data>
  #    <free-form content; just has to follow the block indentation>
  #
  # - MJD:
  #    START: <start of observation in 'mjd' (unit:days)>
  #    END:   <end of observation in 'mjd' (unit:days)>
  #
  # - ARTICLE:
  #    label: <bibcode or alike>
  #    url:   <any url important for the user to understand the data>
  #    arxiv: <if published, the article's arXiv url>
  #    ads:   <if published, the article's ads reference url>
  #
  # - COMMENTS:
  #    Name:          <a label, typically the file rootname>
  #    Tag:           <a short, contiguous label>
  #    Redshift:      <z>
  #    LiveTime:      <observation time in hours>
  #    Significance:  <significance value>
  #
  # - SED_TYPE: diff_flux_points
  #
  # datatype:
  # - name: e_ref
  #   unit: TeV
  #   datatype: float64
  # - name: dnde
  #   unit: ph / (m2 TeV s)
  #   datatype: float64
  # - name: dnde_errn
  #   unit: ph / (m2 TeV s)
  #   datatype: float64
  # - name: dnde_errp
  #   unit: ph / (m2 TeV s)
  #   datatype: float64
  #
  e_ref dnde dnde_errn dnde_errp
  <...> <...> <...> <...>
