Master: [![Circle CI](https://circleci.com/gh/CoursAvenue/CoursAvenue/tree/master.svg?style=svg&circle-token=80404fff1a5d1ea3f2feeccdc644fd8e75df36b0)](https://circleci.com/gh/CoursAvenue/CoursAvenue/tree/master)

Staging: [![Circle CI](https://circleci.com/gh/CoursAvenue/CoursAvenue/tree/staging.svg?style=svg&circle-token=80404fff1a5d1ea3f2feeccdc644fd8e75df36b0)](https://circleci.com/gh/CoursAvenue/CoursAvenue/tree/staging)

# CoursAvenue

The old readme is available [here](doc/README.md).

- [Local environment](#local-environment)
  - [Ruby](#ruby)
  - [Dependencies](#dependecies)
  - [NodeJS](#nodejs)
  - [Install Java](#install-java)
  - [Environment Variables](#environment-variables)
  - [Pow](#pow)
  - [Prerender](#prerender)
  - [Sunspot](#sunspot)
  - [Testing](#testing)
  - [Rubocop](#rubocop)
  - [Git](#git)
- [Continuous Integration](#continuous-integration)
  - [Configuration](#configuration)
- [Deployment](#deployment)
  - [Pushing to Production](#pushing-to-production)
  - [Pushing to Staging](#pushing-to-staging)
- [Production and Staging environments](#production-and-staging-environments)
  - [Prerender](#prerender)
- [Random stuff](#random-stuff)
  - [Delayed Jobs](#delayed-jobs)
  - [Using where with an attribute of type `hstore`](#using-where-with-an-attribute-of-type-hstore)
  - [Create a Sitemap](#create-a-sitemap)
  - [Installing `postgres` and creating a Role](#installing-postgres-and-creating-a-role)
  - [Create a user for postgres](#create-a-user-for-postgres)
  - [Recovering a dump](#recovering-a-dump)
  - [Making a dump](#making-a-dump)
  - [SMS with Nexmo](#sms-nexmo)
  - [Icon webfont](#webfont)

## Local environment

## Setup script

A setup script is available. Just run `./script/setup` to get started.

### Ruby
We use [Rbenv][rbenv] to locally manage our ruby version. The version is defined
in the [Gemfile][gemfile].

### Dependencies

Install Postgres and Memcached using [Homebrew][brew]:

```sh
brew install postgresql memcached
```

Follow the post-install instructions to make sure they automagically launch at
startup.

### NodeJS

We are using [Browserify][browserify] to take advantage of modules in JavaScript. This means
you need to install [`node`][node], either using the official installer or
Homebrew[brew]. After installing you need to install the JavaScript
dependencies:

```sh
# Install node.
brew install node # Or double click on that installer

# Install JavaScript deps.
npm install
```

Make sure to install dependencies on a regular interval, after changing branch,
etc.

### Install Java

Java should ask to install itself on the first Solr run.

### Environment Variables
We store all our sensitive data in the environment. Those variable are located
in the [`.env`][env] file. You can create your own by copying the file
[`.env.sample`][env] and editing it. Those variables are loaded in your
environment thanks to the gem [`dotenv-rails`][dotenv].

### Pow
We use [Pow][pow] for local development to be able to access the application on
the domain `http://coursavenue.dev`. To make sure Pow uses the right version of
Ruby, you need to add the path to Rbenv's executable folder in Pow's
configuration file [`~/.powconfig`][powconfig]:

```shell
# ~/.powconfig
export PATH=$(rbenv root)/shims:$(rbenv root)/bin:$PATH
```

### Prerender
In Production and Staging, we use [Prerender][prerender] to render our
JavaScript heavy views and store them in S3 so they can be served to bots and
crawlers. It is not necessary to use it in local development, but in case you
need it you need to install it locally.

```shell
# In another folder:
$ git clone git@github.com:CoursAvenue/coursavenue-prerender.git
$ cd coursavenue-prerender

# Install dependecies, including PhantomJS
$ npm install

# Run (in foreground)
$ node server # or foreman start -p 3000
```

After installing it, you need to tell the CoursAvenue application the URL to the
Prerender service and to run it:

```shell
# Add it the environment so CoursAvenue knows about it.
$ echo "PRERENDER_SERVICE_URL: 'http://prerender.dev'" >> .env

# Run it with Pow
$ echo 3000 > ~/.pow/prerender
$ touch ~/.pow/restart.txt
```

To access CoursAvenue as a bot, you can either
* Change your user agent to
```
Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
```
* Or, visit the page adding `?_escaped_fragment_=` to the page URL.

### Sunspot

We use [Sunspot][sunspot] power our search. Locally, you need to run manually
run it every time you start the application. To launch it:

```shell
$ bundle exec rake sunspot:solr:start
```

### Testing

To run the tests, run the following commands:

```shell
$ bundle exec rake db:test:clone # Optional
$ bundle exec rspec
```

This will also generate a test coverage that can be found in
`coverage/index.html`.

If you want to run the test without generating a coverage, run this
command instead:

```shell
$ CI=1 bundle exec rspec
```

By default, most of the mailers are disabled. If your spec requires testing
whether an email has been sent or not, you can re-enable emails by adding the
tag `with_email`:

```ruby
it 'sends two emails', with_email: true do
  expect { subject.my_cool_method! }.to change{ ActionMailer::Base.deliveries.count }.by(2)
end
```

### Rubocop

Run [Rubocop](https://github.com/bbatsov/rubocop/):

```shell
bundle exec rubocop -c config/hound.yml
```

### Git

We develop a lot using branches, so you can locally find yourself with a lot of
unused old branches. To remove them:

```shell
# Remove local branch
git branch -D branch_name

# Remove remote branch
# Remove from the website or
git push origin :branch_name

# Remove remote refs from local
$ git gc --prune=now
$ git remote prune origin
```

## Continuous Integration

We use [CircleCI][ci] as continuous integration. Every time you push to GitHub,
CircleCI will run the test on its server and execute actions depending on the
outcome of the tests. After every tests, it will send a notification to Slack.

### Configuration

The CircleCI configuration is done via the [`circle.yml`][ci-config] file in our
repo and via the test environment variables set on [CircleCI][ci-env-vars].

We use a deployment script located in [`script/ci_heroku_deploy`][ci-deploy]
that depending on the branch pushes to Production or Staging and depending on
the changes migrates or not the database.

## Deployment

### Pushing to Production

To push to Production, simply push the master branch to GitHub. If all the tests
pass, it will deploy to Production and the migrations will be made if needed.

```shell
$ git push origin master
```

To skip the CI, directly push to Production. You will still need to manually
run the migrations if they are needed:
```shell
$ git push production master && \
    hk run 'rake db:migrate' -a production
```

### Pushing to Staging

To push to Staging, push any branch to GitHub and the term '[deploy]' anywhere
in the commit message. If all tests pass, it will deploy to Staging and the
migration will be made if needed.

```shell
$ git push origin my-awesome-branch
```

To skip CI, directly push to Staging. You will need to force the push, and you
will still need to run the migrations if they are needed:

```shell
$ git push staging my-awesome-branch:master -f && \
    hk run 'rake db:migrate' -a staging
```

## Production and Staging environments

### Prerender

Depending on the environment, you need to add the `PRERENDER_SERVICE_URL`
variable:
```shell
# Staging
$ heroku config:set \
    PRERENDER_SERVICE_URL="http://coursavenue-prerender-staging.herokuapp.com/"

# Production
$ heroku config:set \
    PRERENDER_SERVICE_URL="http://coursavenue-prerender.herokuapp.com/"
```

And finally add the task `rake scheduler:ping` to the scheduler so the Prerender
service can keep running.

## Random stuff

### Delayed Jobs

Reinvoke all jobs:
```ruby
Delayed::Job.where.not(last_error: nil).each{ |dj| dj.run_at = Time.now; dj.attempts = 0; dj.save! }
```

### Using where with an attribute of type `hstore`:

```ruby
User.where("meta_data -> 'subscription_from' LIKE 'newsletter'")
```

### Create a Sitemap

```shell
$ RAILS_ENV=production rake sitemap:create
```

### Installing `postgres` and creating a Role

```shell
brew install postgres
psql postgres
create role postgres with login createdb createrole password 'password';
ALTER USER postgres WITH SUPERUSER;
create role udrhnkjoqg1jmn with login createdb createrole password 'password';
```

### Create a user for postgres
http://stackoverflow.com/questions/17633422/psql-fatal-database-user-does-not-exist

### Recovering a dump

```shell
killall ruby
dropdb -h localhost -U postgres coursavenue_development
createdb -h localhost -O postgres -U postgres coursavenue_development && \
psql coursavenue_development -c 'create extension hstore;' -U postgres && \
pg_restore --host localhost --port 5432 --username "postgres" --dbname "coursavenue_development" --role "ue4n5u63uise37" --no-password  --verbose "/Users/Nima/Downloads/a569.dump"

pg_restore --host localhost --port 5432 --dbname "coursavenue_development" --role "ue4n5u63uise37" --verbose /Users/Nima/Downloads/a686.dump -U postgres
```

### Making a dump

```shell
pg_dump --host localhost --port 5432 --username "postgres" --dbname "coursavenue_development" -f 20_fev.tar --format=t
```

### SMS with Nexmo

Add to the environment the Nexmo [API key and secret](https://dashboard.nexmo.com/private/settings):

### Icon webfonts
We use FontAwesome and Fontcustom to generate own icon font
Command to regenerate fonts:
```sh
bundle exec fontcustom compile app/assets/images/icons/svg/
```

[ci]: https://circleci.com
[ci-config]: circle.yml
[ci-env-vars]: https://circleci.com/gh/CoursAvenue/CoursAvenue/edit#env-vars
[ci-deploy]: script/ci_heroku_deploy
[pow]: http://pow.cx
[env]: .env.sample
[dotenv]: https://github.com/bkeepers/dotenv
[rbenv]: https://github.com/sstephenson/rbenv
[powconfig]: http://pow.cx/manual.html#section_3
[gemfile]: Gemfile
[prerender]: https://github.com/CoursAvenue/coursavenue-prerender
[sunspot]: http://sunspot.github.io
[brew]: http://brew.sh
[node]: https://nodejs.org/
[Browserify]: http://browserify.org/
