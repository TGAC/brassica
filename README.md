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

Database user must be allowed to create databases and enable extensions.

Create and bootstrap the database:

    bin/rake db:create:all
    bin/rake app:bootstrap

This will load production data, migrate it and initialize ES indices.

The `app:bootstrap` task may be used at a later time to reset database to its
initial state but make sure that no instance of the app is running when calling the task.


## Deployment

So far there is only one environment - production. In order to deploy first
you need to:

* add bip-deploy host to your `~/.ssh/config` (see internal docs)
* make sure your SSH key is authorized by gateway and deployment servers

To perform deploy run:

    bin/cap production deploy


## Testing

    bin/rspec


