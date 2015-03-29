# Brassica Information Portal

TODO:

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Dependencies

* MRI 2.2.0
* postgresql, libpq-dev
* Elasticsearch 1.4.3, Java 7


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

Install required gems:

    bundle

Make sure `config/database.yml` is in place and contains correct configuration:

    cp config/database.yml.sample config/database.yml

Database user must be allowed to enable extensions.

Create databases:

    bin/rake db:create db:migrate db:seed db:test:prepare

Initialize Elasticsearch indices:

    bin/rake environment elasticsearch:import:all


## Testing

    bin/rspec


