# VERITAS-BSDC

This repository contains software and main setup files in use by [BSDC] to receive, transform and publish [VERITAS] *spectra* through [VO].

The pipeline implemented is composed by three blocks:
1. data delivery
2. processing
3. publishing

The first block -- `data delivery` -- is done through [Syncthing], a files synchronization software.
When a new file arrive, an existing is modified or deleted, it triggers second part of the pipeline.

Block two -- `processing` -- fundamental purpose is to transform the (new) file's content to something suitable to be published through VO *spectra* service.
The main task is done by <a href="proc/csv2fits.py">csv2fits.py</a> script. 
Pre- and post-processing tasks are carried by <a href="post/archive_update.sh">archive_update.sh</a> script.
At the end of the processing block, if everything goes fine, the publishing database is updated.

Data `publishing` is done using [GAVO-DaCHS].
The configuration file, i.e <a href="q.rd">database schema</a> set up a [VO-SSAP] service and a web interface.

The final result -- VERITAS spectra -- can be accessed through [BSDC-VERITAS page] or any VO-compliant software (e.g, [Topcat], [Aladin]).


Carlos Brandt, on behalf of the BSDC collaboration

[BSDC]: http://vo.bsdc.icranet.org
[VERITAS]: https://veritas.sao.arizona.edu/
[VO]: http://ivoa.net/
[Syncthing]: https://syncthing.net/
[GAVO-DaCHS]: http://docs.g-vo.org/DaCHS/
[VO-SSAP]: http://www.ivoa.net/documents/SSA/
[BSDC-VERITAS]: http://vo.bsdc.icranet.org/veritas/q/web/form?__nevow_form__=genForm&_DBOPTIONS_ORDER=&_DBOPTIONS_DIR=ASC&MAXREC=100&_FORMAT=HTML&submit=Go
[Topcat]: http://www.star.bris.ac.uk/~mbt/topcat/
[Aladin]: http://aladin.u-strasbg.fr/
