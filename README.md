## Brassica Information Portal

The Brassica Information Portal (BIP) is a web repository for population and trait scoring information related to the Brassica breeding community. Advanced data submission capabilities and APIs enable users to store and publish their own study results in our Portal.
Release embargos can be placed on datasets to reflect the need for scientists to publish their data in time with associated publications. The repository can be easily browsed thanks to a set of user-friendly query interfaces. Data download can be achieved using the API to feed into downstream analysis tools or via the web-interface.

The portal caters for the growing interest in phenotype data storage, reproducibility, and user controlled data sharing and analysis in integrated genotype-phenotype association studies aimed for crop improvement.
The use of ontologies and nomenclature will make it easier to make conclusions on genotype-phenotype relationships within and across Brassica species.
We currently use [Plant and Trait Ontology](http://archive.gramene.org/plant_ontology/ontology_browse.html#tax) as reference ontologies for plants,
[GR_tax ontology ](http://archive.gramene.org/plant_ontology/ontology_browse.html#tax) to cover Brassica taxonomy,
[Plant Experimental Conditions Ontology](http://browser.planteome.org/amigo/term/EO:0007359) and
[Crop Research Ontology](http://www.cropontology.org/ontology/CO_715/Crop%20Research) to describe plant treatment and
environment, and [Unit Ontology](https://github.com/bio-ontology-research-group/unit-ontology) for measurement units.
Marker sequences are currently cross-referenced with resources such as [Genebank(NCBI)](https://www.ncbi.nlm.nih.gov/genbank/)
and [EnsemblPlants](https://plants.ensembl.org/index.html) where possible, which will be expanded in the future.

It is a Rails web application is released as a free and open source project (see the LICENSE.txt file). The underlying database schema is derived from the CropStoreDB schema ver.7, with the original version developed by <a href="mailto:Graham.King@scu.edu.au">Graham King</a> and Pierre Carion at [Rothamsted Research](https://www.rothamsted.ac.uk/).

BIP is a community project, we kindly welcome any contributions to improve existing and add new functionalities. If you wish to deploy a copy of BIP (for Brassica or any other crop) on your own servers, don’t hesitate to contact us <a href="mailto:bip@earlham.ac.uk">bip@earlham.ac.uk</a> in case you need our assistance. Contacting us also helps measuring the software impact and planning future developments.  If you are interested in contributing to the project, for example by adding any analytics tools, please contact us, too. We are looking forward any feedback!
For further contact information on people behind the project or the database itself, please see the [about us](https://bip.earlham.ac.uk/about) section.

Also, follow the BIP on twitter to get the latest updates [@BrassicaP](https://twitter.com/BrassicaP).

If you are interested in learning how to submit data to the portal, training material is available on [BIP_training](https://github.com/TGAC/BIP_training).

Currently, the web application is still under development and also changes to the database schema are possible. Despite these ongoing developments, navigation, data submissions and -download from the EI-hosted BIP version via the web-interface and the API should be possible.

## Cite
Eckes AH, Gubała T, Nowakowski P et al. Introducing the Brassica Information Portal: Towards integrating genotypic and phenotypic Brassica crop data [version 1; referees: awaiting peer review]. F1000Research 2017, 6:465 (doi: 10.12688/f1000research.11301.1)

Tomasz Gubała, Tomasz Szymczyszyn, Piotr Nowakowski, Bogdan Chucherko, Annemarie H. Eckes, Sarah C. Dyer, & Wiktor Jurkowski. (2017). TGAC/brassica: v1.0.0 [Data set]. Zenodo. http://doi.org/10.5281/zenodo.466050
https://zenodo.org/badge/DOI/10.5281/zenodo.466050.svg


## Dependencies

* Ruby >= 2.0
* MRI 2.2.x
* PostgreSQL
* Elasticsearch 2.4.6, Java 7
* R >= 3.2.2
* [GWASSER](https://github.com/kammerer/GWASSER) (forked from [cyverseuk/GWASSER](https://github.com/cyverseuk/GWASSER))
* [GAPIT](http://www.maizegenetics.net/gapit)


### Elasticsearch

In Debian / Ubuntu / Mint Linux installation might be as easy as:

    sudo apt-get install elasticsearch

If your distro does not include this package
use [instructions from elasticsearch.org](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/setup-repositories.html).

Use `service` command to control the server:

    sudo service elasticsearch start

In order to inspect it you can use [ElasticHQ](http://www.elastichq.org/gettingstarted.html) (plugin option
is quick and easy).


## Installation

To start installation clone brassica repository:

    git clone  https://github.com/TGAC/brassica.git

Navigate to source code location and install required gems:

    bundle

Make sure `config/database.yml` is in place and contains correct configuration:

    cp config/database.yml.sample config/database.yml

Database user must be allowed to create databases and enable extensions.

Create and bootstrap the database:

    bin/rake db:create:all
    bin/rake app:bootstrap

This will load production data, migrate it and initialize ES indices.

The `app:bootstrap` task may be used at a later time to reset database to its
initial state but make sure that no instance of the app is running when calling the task.

Also, make sure `config/admins.yml` is in place and contains ORCiD identifiers of users with admin privileges:

    cp config/admins.yml.sample config/admins.yml


### R packages

This application relies on a set of tools and packages being installed on the server, so
respective elements of the application can call them, spawning new system processes.

After installation you will need to setup your R environment. Run the "R" executable
in your shell and issue the following commands from R prompt (you may do that either
system-wide, with `sudo`, or just for your user).


#### GWASSER dependencies

 - `install.packages('lme4')`
 - `install.packages('argparse')`
 - `install.packages('dplyr')`
 - `install.packages('lmerTest')`


#### GAPIT dependencies

 - `source("http://www.bioconductor.org/biocLite.R")`
 - `biocLite('multtest')`
 - `biocLite('chopsticks')`
 - `install.packages('gplots')`
 - `install.packages('genetics')`
 - `install.packages('LDheatmap')`
 - `install.packages('ape')`
 - `install.packages('EMMREML')`
 - `install.packages('scatterplot3d')`
 - `install.packages('argparse')`


### Configuration

Please also make sure to set required environment variables in your `.env` file. You can use `.env.sample` as
a template.

#### GWAS

```
ANALYSIS_EXEC_DIR=<full path to analysis working directory>
GWAS_GWASSER_SCRIPT=<full path to the GWASSER.R executable script>
GWAS_GAPIT_SCRIPT=<full path to the app dir>/lib/GAPIT/runner.R
GWAS_GAPIT_DIR=<full path to a dir containing gapit_functions.txt and emma.txt>
```

The analysis working directory needs to be an empty directory writable by the
application. It is used to run analysis script and store temporary outputs.
The scripts pointed to by config variables should be made executable.


## Background workers

In order to run background jobs in development you can use one of the following
rake tasks:

    # Start a delayed_job worker
    bin/rake jobs:work

    # Start a delayed_job worker and exit when all available jobs are complete
    bin/rake jobs:workoff

If you need to run more processes you can use `bin/delayed_job`
script:

    bin/delayed_job {start,stop,restart} --pool=*:2


## Deployment

So far there is only one environment - production. In order to deploy first
you need to:

* add bip-deploy host to your `~/.ssh/config` (see internal docs)
* make sure your SSH key is authorized by gateway and deployment servers

To perform deploy run:

    bin/cap production deploy

If any changes were introduced to ES index definitions or data migrations
affecting indices were performed it is necessary to reindex data:

    bin/cap production search:reindex:all

Or:

    bin/cap production search:reindex:model CLASS=<class name>


## Testing

    bin/rspec


