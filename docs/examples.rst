Examples
================================

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
	

ARS Reduction
------------------------
.. code-block:: shell

	./nextflow run nmdp-bioinformatics/flow-blast-hml -with-docker \
		nmdpbioinformatics/docker-blast-hml \
		--hml test_file.hml --outdir /path/to/output/dir
	
After running this command you should find a report and a validated file in the ouput directory you specified.
