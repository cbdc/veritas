BSDC-VERITAS
############

Hoping to optimize VERITAS *spectra* data publication, a system automating
the whole process -- from the data file validation, to transformation,
to database insertion and publication through VO -- was implemented.
Ideally, a file following the established format is dropped in a
shared filesystem and half-minute after is available through BSDC web
interface and VO network.

The following lines are meant to briefly describe the system, sufficient
to explain the path each file flows through to be published at BSDC_.

.. _BSDC: http://vo.bsdc.icranet.org/veritas/q/web/form

Everything that the VERITAS collaboration needs to deal with is the
software used to synchronize the archives; once a properly formatted
data file (see [v3]_) is added to a uniquely, private directory shared
between VERITAS and BSDC machines, the whole remaining process is
executed on the server side (i.e, BSDC). VERITAS' responsible needs
only to double check the resulting publication and, possibly, the
*log* files given back through the same shared filesystem.

.. [v3] https://github.com/chbrandt/veritas/blob/master/docs/data_formatting-v3.rst


Data synchronization
====================

Shared file system
------------------

The software used to synchronize the archives of VERITAS and BSDC is
Syncthing_; It is a multi-platform, open-source software providing
non-centralized encrypted files synchronization between two-or-more nodes.

The setup of Syncthing_ is straightforward, the is invited to read the
`Getting Started`_ section of the documentation; that should be enough
for our current needs.

.. _Syncthing: https://syncthing.net/
.. _Getting Started: https://docs.syncthing.net/intro/getting-started.html


VERITAS setup
.............

Once the software is running in one of VERITAS machines, let's call it
the "`data machine`", BSDC and VERITAS will exchange the private keys
that allow the identification and effectively synchronize the data
between the nodes.

Currently, the person in charge of this process in VERITAS is Michael Daniel;
in BSDC, Carlos Brandt.

It is never too much to highlight the details:

* "`data machine`" must have access to the internet through the port 22000,
 * port 22000 is the default one used by Syncthing;
* the location of the directory to be shared with BSDC is irrelevant;
* *probably*, VERITAS will prefer to set the shared directory as *Send Only*.

Once VERITAS gets access to BSDC dedicated `veritas` directory, next to
the already existent files, a subdirectory `log/` can be seen; *log* is
where pipeline's `stdout/stderr` outputs are saved for further checkings
by the collaboration after a new file is added.
