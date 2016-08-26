RESTful Calls
================================

Parameters
------------------------
* IMGT/DB
* Glstring
* ARS Type
* MAC Url
* Expand Genotypes
* Expand Genomic Typing


Convert HLA Typing
------------------------
.. code-block:: shell

	./nextflow run nmdp-bioinformatics/flow-blast-hml -with-docker \
		nmdpbioinformatics/docker-blast-hml \
		--hml test_file.hml --outdir /path/to/output/dir

Convert Subject Typing
------------------------
.. code-block:: shell

	./nextflow run nmdp-bioinformatics/flow-blast-hml -with-docker \
		nmdpbioinformatics/docker-blast-hml \
		--hml test_file.hml --outdir /path/to/output/dir

Get ARS Data
------------------------
.. code-block:: shell

	./nextflow run nmdp-bioinformatics/flow-blast-hml -with-docker \
		nmdpbioinformatics/docker-blast-hml \
		--hml test_file.hml --outdir /path/to/output/dir
