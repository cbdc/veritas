BSDC-VERITAS
############

Here goes the description of BSDC participation on VERITAS data
publication.
BSDC aim to be that VO-compliant interface, linking VERITAS and ASDC
SED tool besides any other VO-client.

BSDC will publish VERITAS data through a SSAP service and a web interface.

The basic dimensional space of a spectral dataset containing measurements
from blazars is three dimensional and composed by frequency, flux and epoch.

* frequency (or wavelength, energy)
 * measurement error if applicable
* flux (or flux density)
 * measurement error
* epoch (or MJD)
 * delta, or integration time range


Flux table
==========
The table to use for a SED plot/analysis is basically:

======  ====  =====
energy  flux  epoch
======  ====  =====
E1      F1    t1
E2      F2    t2
...     ...   ...
======  ====  =====

From which a more complete version can be reached with the corresponding
*deltas*:

===  =======  ===  =======  ===  =======
 Energy        Flux          Epoch
------------  ------------  ------------
Em   E_error  Fm   F_error  Ti   T_delta
===  =======  ===  =======  ===  =======
...  ...      ...  ...      ...  ...
===  =======  ===  =======  ===  =======

Clearly the columns have physical units associate and those compose the
set of metadata associated with the table.


Objects table
=============
Each flux table has an object associated.
In the case of VERITAS, there is also an article where the data is
analyzed and explained; such article should also be linked to.

All VERITAS-observed objects (blazars, for instance) are brought in
collection in a table as follows:

======  =======  =======  ======
Object  Article  Epoch    Data
======  =======  =======  ======
*name*  *link*   *start*  *file*
======  =======  =======  ======

Where *name* is an **IAU** designation of the object, *link* is the URL
(ArXiv for instance) where the corresponding article is published, *start*
is the starting **MJD** of the data stored in *file* (the file containing
the flux table).

In case where the article has two values associated with it -- ArXiv URL
and BibCode --, as done in VERITAS, corresponding columns can be added,
keeping the information clear.
For example:

======  =========  ======  =======  ======
Object  Article    Arxiv   Epoch    Data
======  =========  ======  =======  ======
*name*  *bibcode*  *link*  *start*  *file*
======  =========  ======  =======  ======

*Epoch* is important here for two reasons.
The first one is to enable a user first-look to see whether such data
is useful, if (s)he is analyzing the objects *before* VERITAS observation
probably it will be of no value.
But a better reason -- for VERITAS -- is because the collaboration likes
to split its datasets according to the object's state: low/high emission
periods.
As an example, look for **Mrk 501** entries in the second table at
`veritas-blazars page <http://veritas.sao.arizona.edu/veritas-science/veritas-blazar-spectra>`_.
There we will see in the column named *Blazar* seven different entries:

* Mrk 501 (high A)
* Mrk 501 (high B)
* Mrk 501 (high C)
* Mrk 501 (low)
* Mrk 501 (mid)
* Mrk 501 (very high)
* Mrk 501 (very low)

, but all of them are from the same article and obviously the same object.
But this is not the best approach I'd say.
The use of *Epoch* is a better solution, since the epochs will never be
the same.
Another approach is to move the comments ("high A", "mid", "very low")
to another column name, for example, *Notes*.

It is important to keep each column's content clean and exposing information
accordingly.


Data file format
================
It is important for a data file to be self-consistent and provide clear
information; a good structure can help both human and computers to
understand the data it provides.

ASCII (text) files can be a good solution if data is light and easy access
to its contents is a major requirement (since any text editor will do it).
But it important then to *define* a structure, a format for the information
in it.

CSV
---
A good way to place table data in an ASCII file is to use and extend
the well known CSV file format.
CSV stands for Comma-Separated Values: columns are separated by "," or ";"
characters.
Usually, ";" is the preferred choice in astrophysics since our numerical
tables can have values with "," character in it, but hardly (if ever) ";".

The CSV "standard" recognizes "#" as the *comment* character: lines
starting with "#" are not considered valid values (not part of the data table).
Extra information, like notes or metadata, relavant to put the data
in context can be put after "#".

An enhanced version of the CSV format can be an easy and straightforward
solution.
Below, a suggestion of a better, more complete version of data file
(data and metadata assembled from VERITAS-blazars page, but not
to be taken as valid, useful values):

```
# object: Mrk 501
# mjd: 54905
#
# article:
#   label: Ap.J. 727, 129 (2011)
#   arxiv: http://arxiv.org/abs/1011.5260
#
# description: >
#   Spectral energy distribution for Mrk 501 averaged over all
#   observations taken during the multifrequency campaign performed
#   between 2009 March 15 (MJD 54905) and 2009 August 1 (MJD 55044).
#
# columns:
#   - name: E
#     unit: TeV
#   - name: phi
#     unit: TeV-1 s-1 m-2
#   - name: ephi_low
#     unit: TeV-1 s-1 m-2
#   - name: ephi_up
#     unit: TeV-1 s-1 m-2
0.275	1.758E-005	5.721E-007	5.721E-007
0.340	1.096E-005	3.148E-007	3.148E-007
0.420	7.052E-006	2.092E-007	2.092E-007
0.519	4.245E-006	1.330E-007	1.330E-007
0.642	2.432E-006	8.439E-008	8.439E-008
0.793	1.403E-006	5.487E-008	5.487E-008
0.980	8.388E-007	3.642E-008	3.642E-008
```

We can improve the data and metadata associated as necessary, as suggestion
in the above sections.


Other formats
-------------
There are other clear and broadly accepted formats.

`IPAC <http://irsa.ipac.caltech.edu/applications/DDGEN/Doc/ipac_tbl.html>`_
is one of them, well known for those using IRAS (but not only) data.

`ECSV <https://github.com/astropy/astropy-APEs/blob/master/APE6.rst>`_,
from where the suggestion above is based on, is a fairly recent format
proposed by AstroPy collaboration.


Conclusion
==========
Numerous options for standard file formats are available, innumerous
possibilities can be found to properly structure the data.
Most important is to define a structure where each kind and type of data
is uniquely stored and so may be unequivocally retrieved.
