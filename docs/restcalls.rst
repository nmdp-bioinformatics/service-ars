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

	curl --header "Content-type: application/json" --request POST 
		--data '{"arsFile":"hla_nom_g.txt","dbversion":"3.20.0","arsType":"G",
		"Subjects":[{"SubjectID":1,"typing":["A*01:01+A*01:02","B*08:01+B*07:02","C*07:01+C*07:01"]},
		{"SubjectID":1,"typing":["A*01:01+A*01:02","B*08:01+B*07:02","C*07:01+C*07:01"]}]}' 
		http://localhost:3000/api/v1/reduxSubjects

Convert Subject Typing
------------------------
.. code-block:: shell

	curl --header "Content-type: application/json" --request POST 
		--data '{"arsFile":"hla_nom_g.txt","dbversion":"3.20.0","arsType":"G",
		"Subjects":[{"SubjectID":1,"typing":["A*01:01+A*01:02","B*08:01+B*07:02","C*07:01+C*07:01"]},
		{"SubjectID":1,"typing":["A*01:01+A*01:02","B*08:01+B*07:02","C*07:01+C*07:01"]}]}' 
		http://localhost:3000/api/v1/reduxSubjects

Get ARS Data
------------------------
.. code-block:: shell

	./nextflow run nmdp-bioinformatics/flow-blast-hml -with-docker \
		nmdpbioinformatics/docker-blast-hml \
		--hml test_file.hml --outdir /path/to/output/dir
