BSDC-VERITAS
############

After a first proposal for VERITAS data (*spectra*, for instance) files
format [v1]_, we go here for a second iteration after Michael Daniel's
feedback, adding some features from `SED data format for gamma-ray astronomy`__.

.. [v1] see `data_formatting-v1.rst`
.. _dfgra: http://gamma-astro-data-formats.rtfd.io/en/latest/spectra/flux_points/
__ dfgra_


SED-types
=========
One important feature raised by Michael is the inclusion and adoption of
standards established by the `gamma-ray astronomy effort on data format`__,
in particular, in what regards the *spectrum*/SED files.

__ dfgra_

VERITAS *spectrum* files provide *differential flux* measurements;
columns represent:
- the `energy` from which flux measurement is referred to
- the `differential flux` measured
- the `asymmetric negative flux error`
- the `asymmetric negative flux error`

According to those standards, we can improve the use of such data by
including the keyword `SED_TYPE` in the file headers.
The standard proposes the value `dnde`, Michael proposes a more comprehensive
value:
```
SED_TYPE = diff_flux_points
```

And columns go labeled after the standard:
- `e_ref`: the reference measurement energy
- `dnde`: differencial flux values
- `dnde_errn`: negative flux error
- `dnde_errp`: positive flux error


ECSV
====
The file format ECSV (version 0.9), as proposed by Astropy's APE-6_ is
to be used as it is a good compromise for human readability and metadata-
rich format for lightweight data files.

The *Extended CSV* lies over YAML_ data (serialization) format.
In what follows, it is described the new proposal for data format to
be used with VERITAS *spectra*; an example file is taken as example.

.. _APE-6: https://github.com/astropy/astropy-APEs/blob/master/APE6.rst
.. _YAML: http://yaml.org/spec/1.2/spec.html


Data format:
============

Let us consider the file for *Markarian-421* in a high state between
`2008-02-06` and `2008-06-05` as published in `arXiv:1106.1210`_::

  # %ECSV 0.9
  # ---
  # meta: !!omap
  # - object: Mrk 421
  #
  # - description:
  #    Spectral points for multiwavelength campaign;
  #    Observations taken between 2008 January 01 and 2008 June 05;
  #    Flux sensitivity 0.8e-10 < flux(E>1TeV) < 1.1e-10
  #
  # - mjd:
  #    start: 54502.46971
  #    end: 54622.18955
  #
  # - article:
  #    label: Ap.J. 738, 25 (2011)
  #    url: http://iopscience.iop.org/0004-637X/738/1/25/
  #    arxiv: http://arxiv.org/abs/1106.1210
  #    ads: http://adsabs.harvard.edu/abs/2011ApJ...738...25A
  #
  # - comments:
  #    - Name=Mrk421_2008_highA
  #    - z=0.031
  #    - LiveTime(h)=1.4
  #    - significance=73.0
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


.. _arXiv:1106.1210: https://arxiv.org/abs/1106.1210

-----

::

  # %ECSV 0.9
  # ---

Mandatory directive, as the very first two lines of the file.


::

  # meta: !!omap

as well as `# datatype:` (below) are mandatory (first-level) collections.
In fact, `meta` and `datatype` are the only two first-level blocks that
ECSV-0.9 accepts.

Notice the argument `!!omap`; this is a mandatory *tag* (in yaml's jargon)
for Astropy to succeed in reading it (probably a bug).


`meta` section
--------------

::

  # meta: !!omap

Begin of `meta` section; `!!omap` is mandatory.

::

  # - object: Mrk 421

`object` is the object's designation.
The name of the object is meant to be used to cross-correlate with other
databases and as such must be broadly recognised.
The `object` name should be recognised by Simbad_.

.. _Simbad: http://simbad.u-strasbg.fr/simbad/sim-fid

::

  # - description:
  #    Spectral points for multiwavelength campaign;
  #    Observations taken between 2008 January 01 and 2008 June 05;
  #    Flux sensitivity 0.8e-10 < flux(E>1TeV) < 1.1e-10

`description` is a free-form paragraph used to briefly describe the
content of the file.

::

  # - mjd:
  #    start: 54502.46971
  #    end: 54622.18955

The (*spectra*) data points reported do not pursue a MJD (or MJD-range).
Instead, data points are grouped (in data files, like this one) according
to the object's activity and the period of time.
That said, the `mjd` (values, `mjd`-range) is reported to all the *spectrum*
data points, all together; `start` and `end`.

::

  # - article:
  #    label: Ap.J. 738, 25 (2011)
  #    url: http://iopscience.iop.org/0004-637X/738/1/25/
  #    arxiv: http://arxiv.org/abs/1106.1210
  #    ads: http://adsabs.harvard.edu/abs/2011ApJ...738...25A

`article` `label` is a higher-level designation of the article.
Whereas `url` holds the address of the (if published) journal;
`arxiv` and `ads` (for ADS-Harvard) are relevant for open access.

::

  # - comments:
  #    - Name = Mrk421_2008_highA
  #    - z = 0.031
  #    - LiveTime(h) = 1.4
  #    - significance = 73.0

`comments` are suggested to be placed as list items (preceded by `-`)
if they are short and dettached.
Otherwise, like in `description`, `comments` can be a paragraph,
contiguous block of text spanning multiple lines to form a higher-level
note about the data.

::

  # - SED_TYPE: diff_flux_points

Following the SED standard, `SED_TYPE` defines the type of *spectrum*
we should expect from the data points in the table.
The following options are supported:
- `diff_flux_points` (synonym for `dnde`)


`datatype` section
------------------

::

  # datatype:

Begin of `datatype` section.

::

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

Columns `e_ref`, `dnde` are mandatory for `SED_TYPE = dnde`.
`unit` information for each column are mandatory as well.
`datatype` for each column is a Astropy/ECSV requirement.


Conclusion
==========
Data files are now in a much better shape. Michael's attention to the
SED standard been built by the gamma-ray community is an important
aspect to merge efforts on better describing datasets.
Regarding the ECSV format, we could arrange our information using the
Astropy's format so that metadata stays clear and readability is gain
through the use of a stable, broadly use library.

Next step is to test this format with other (VERITAS) datasets and see
whether their/other datasets' metadata fit properly, and fix/re-propose
the format to accomplish the needs.
Also, it is important to see how to manage datasets (files) from different
epochs (MJDs) but same objects -- which is the case for VERITAS' datasets.
