# service-ars
RESTful Service for Antigen Recognition Site Reduction

### Using service-ars

## RESTful Calls

ARS Reduction on typing data
```bash
     curl http://localhost:3000/api/v1/redux?typing=A*01:01?dbversion=3.20
```

ARS Reduction on multiple subjects
```bash
    curl --header "Content-type: application/json" --request POST 
    --data '{"arsFile":"hla_nom_g.txt","dbversion":"3.20.0","arsType":"G",
    "Subjects":[{"SubjectID":1,"typing":["A*01:01+A*01:02","B*08:01+B*07:02","C*07:01+C*07:01"]},
    {"SubjectID":1,"typing":["A*01:01+A*01:02","B*08:01+B*07:02","C*07:01+C*07:01"]}]}' 
    http://localhost:3000/api/v1/reduxSubjects
```

Get ARS data structure
```bash
    curl http://localhost:3000/api/v1/ars
```

Get ARS data structure for a particular IMGT/DB version
```bash
    curl http://localhost:3000/api/v1/ars?dbversion=3.20.0
```

## Tools

ex. test1.json
```bash
{  
   "arsFile":"hla_nom_g.txt",
   "dbversion":"3.20.0",
   "arsUrl":"http://localhost:3000",
   "macUrl":"http://devgenomicservices1.nmdp.org/mac",
   "arsType":"g"
}
```


# Java
```bash
hml-typing-resolution

arguments:
   -a, --about  display about message [optional]
   -h, --help  display help message [optional]
   -i, --input-file [class java.io.File]  input file, default stdin [optional]
   -j, --json-file [class java.io.File]  json configuration file [required]
   -x, --xml  print output as xml [optional]
   -s, --json  print output as json [optional]
   -c, --csv  print output as csv [optional]

```

ex. hml-typing-resolution
```bash
hml-typing-resolution -j test1.json -x < inputFile.xml > outputFile.xml
hml-typing-resolution -j test1.json -x -i inputFile.xml > outputFile.xml
hml-typing-resolution -j test1.json -c -i inputFile.xml > outputFile.csv
hml-typing-resolution -j test1.json -s -i inputFile.xml > outputFile.json
```

# Perl
```bash
./ars-resolution [--config] [--verbos] [--help]
-c/--config
-v/--verbose
-h/--help
```

ex. ars-resolution
```bash
ars-resolution -c test1.json < testInput.csv > testOutput.csv
```


### Installing

## Required Software

 * JDK 1.7 or later, http://openjdk.java.net
 * Apache Maven 3.2.5 or later, http://maven.apache.org
 * Git, http://git.org
 * perl 5.18 or later, http://perl.org

## Perl Modules

 * YAML 
 * Plack 
 * Plack::Handler::Starman 
 * Template 
 * JSON 
 * Getopt::Long 
 * LWP::UserAgent 
 * Test::More Dancer

### Documentation

 * [readthedocs.org](http://search.maven.org/#search|ga|1|g%3A%22org.nmdp.ngs%22)
 * [docker-ars](http://search.maven.org/#search|ga|1|g%3A%22org.nmdp.ngs%22)
 * [dockerhub](http://search.maven.org/#search|ga|1|g%3A%22org.nmdp.ngs%22)

Docker Image
[![](https://images.microbadger.com/badges/image/nmdpbioinformatics/docker-ars.svg)](http://microbadger.com/images/nmdpbioinformatics/docker-ars "Get your own image badge on microbadger.com")[![](https://images.microbadger.com/badges/version/nmdpbioinformatics/docker-ars.svg)](http://microbadger.com/images/nmdpbioinformatics/docker-ars "Get your own version badge on microbadger.com")



