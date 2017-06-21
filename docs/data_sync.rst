BSDC-VERITAS
############

Hoping to optimize VERITAS *spectra* data publication, it was implemented
a system automating the whole process, from data retrieval to publication.
Ideally, a data file following a particular format is saved in a
shared filesystem hosted by BSDC and, after a minute or so, the new
dataset is available BSDC_ webpage and to the VO network.

The following lines explain the system designed for VERITAS.
The guidelines to the implementation of the system are:

* to give VERITAS collaboration the autonomy to add/remove datasets as pleased
* to provide an easy, seamlessly publishing engine
* to instantly integrate with VO

From the VERITAS perspective, the publication system is a one-step process,
done on a collaboration's owned machine; no need to get in touch with
any of BSDC machines.
After the file is transfered, it flows through a pipeline where data and
metadata is verified, transformed, versionized, finally published.

Everything that the VERITAS collaboration needs to deal with is the
software used to synchronize the archives; once a properly formatted
data file (see [v3]_) is added to a unique, private directory shared
within VERITAS and BSDC machines, the whole remaining process isdisguised.
Then VERITAS needs only to double check the resulting publication and,
possibly, the *log* files given back through the same shared filesystem.

.. [v3] https://github.com/chbrandt/veritas/blob/master/docs/data_formatting-v3.rst


Data synchronization
====================

Shared file system
------------------

The software used to synchronize the archives of VERITAS and BSDC is
Syncthing_; It is a multi-platform, open-source software providing
non-centralized encrypted files synchronization between two-or-more nodes.

The setup of Syncthing_ is straightforward, the `Getting Started`_
section provides a clear, easy to test approach to the software setup.

.. _Syncthing: https://syncthing.net/
.. _Getting Started: https://docs.syncthing.net/intro/getting-started.html


Basic setup
...........

For instance, we can test the software by using the standalone package.
We would then download the `latest release`_ for our system, unpack and
get in the according directory.

From there we simply run ``./syncthing`` binary and if the necessary resources
are available it should give a log of succesful log messages; if ``syncthing``
is unable to allocate the necessary resources it will fall back to the
command line.

Among the resources, the default setup will try to connect to two `TCP`
ports, ``tcp:8384`` for the *gui* (Graphical User Interface) interface
and ``tcp:22000`` for files synchronization with the outside world.
If the default ports do not fit your environment, both can be chaged.

To change the *gui* interface access port (and possibly the allowed IPs),
the command line argument ``-gui-address=""`` can be used when starting
``syncthing``.

The files synchronization port instead must be changed in the config
file[*]_. Nevertheless a simple modification where a line like the
following will setup the service to use port `8080` instead:

code::
  (...)
  <listenAddress>tcp://0.0.0.0:8080</listenAddress>
  (...)


.. _latest release: https://github.com/syncthing/syncthing/releases/latest
.. [*] https://docs.syncthing.net/users/config.html#listen-addresses


VERITAS setup
.............

Once the software is running in one of VERITAS machines (let's call it
the "``data machine``"), BSDC and VERITAS will exchange the private keys
that allow the identification and effectively synchronize the data
between the nodes.
The exchange of private keys should be done on live call.

It is never too much to highlight the details:

* "``data machine``" must have access to the internet through a specific port,
 * port 22000 is the default one used by Syncthing;
* the location of the directory to be shared with BSDC is irrelevant;
* *probably*, VERITAS will prefer to set the shared directory as *Send Only*.

Once VERITAS gets access to BSDC dedicated ``veritas`` directory, next to
the already existent (data) files, a subdirectory ``log/`` can be seen;
*log* is where pipeline's ``stdout/stderr`` outputs are saved for further
checkings by the collaboration after a new file is added.
