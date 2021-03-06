# Production & Staging environment

[Some heroku docs](https://devcenter.heroku.com/articles/multiple-environments)

## Production

### Addons

Using experimental [labs-preboot](https://devcenter.heroku.com/articles/labs-preboot)

```shell
$ heroku labs:enable -a coursavenue preboot
$ heroku labs:disable -a coursavenue preboot
```

## Staging

```shell
$ git push staging master
$ heroku run rake db:migrate --remote staging
$ heroku ps --remote staging
```

### Pushing local branch to heroku staging

```shell
$ git push staging feature_branch:master
```

### Rbenv & Pow

```shell
# ~/.powconfig
export PATH=$(rbenv root)/shims:$(rbenv root)/bin:$PATH
```

### Prerender

#### In prerender app:

```shell
# In another folder:
$ git clone git@github.com:CoursAvenue/coursavenue-prerender.git
$ cd coursavenue-prerender

# Install dependecies, including PhantomJS
$ npm install

$ node server # or foreman start -p 3000
```

#### In Coursavenue App

```shell
$ echo "PRERENDER_SERVICE_URL: 'http://prerender.dev'" >> .env
$ echo 3000 > ~/.pow/prerender
$ touch ~/.pow/restart.txt
```

### In Production / Staging

```shell
$ heroku config:set PRERENDER_SERVICE_URL="http://coursavenue-prerender.herokuapp.com/"
# OR
$ $ hk set PRERENDER_SERVICE_URL='http://prerender.dev'
```

And finally add the task `rake scheduler:ping` to the scheduler, running every xx minutes.

## Testing

* Set the browser user agent to `Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)` and the visit the page, or
* Visit the page adding `?_escaped_fragment_=` to the page URL.

## Dependencies / Gems

### For Will_paginate
A custom renderer has been created in lib/

### SCSS
Inuit.css
Compass for mixins

### Icon webfonts
We use FontAwesome and Fontcustom to generate own icon font
Command to regenerate fonts:
`bundle exec fontcustom compile app/assets/images/icons/svg/`

### Add remote branch for Heroku

```shell
$ git remote add heroku git@heroku.com:coursavenue.git
```


### Heroku

[Using Labs: user-env-compile](https://devcenter.heroku.com/articles/labs-user-env-compile#use-case)

```shell
$ heroku labs:enable user-env-compile -a
```

### Paperclip

Dependencies: imagemagick

#### Reprocessing images

```shell
$ heroku run rake paperclip:refresh CLASS=Course
```

### For Heroku

```shell
$ heroku config:add AWS_BUCKET=bucket_name
$ heroku config:add AWS_ACCESS_KEY_ID=
$ heroku config:add AWS_SECRET_ACCESS_KEY=
```

### [Solr sunspot](https://github.com/sunspot/sunspot#readme)

Commands
```shell
$ rake sunspot:solr:run
```

On heroku
```shell
$ heroku run rake sunspot:solr:start
$ heroku run rake sunspot:solr:stop
$ heroku run rake sunspot:reindex
```


### Git

```shell
# Remove local branch
$ git branch -D branch_name

# Remove remote branch
$ git push origin :branch_name

# Remove remote refs from local
$ git gc --prune=now
$ git remote prune origin
```

### Cities
http://download.geonames.org/export/zip/

### Sitemap

```shell
$ RAILS_ENV=production rake sitemap:create
```

### Tests
```shell
$ rake db:test:clone
$ RAILS_ENV=test rake sunspot:solr:start
$ rspec spec
```

# DB

## Install Postgres and create role

    brew install postgres
    psql postgres
    create role postgres with login createdb createrole password 'password';
    ALTER USER postgres WITH SUPERUSER;
    create role udrhnkjoqg1jmn with login createdb createrole password 'password';


## Recovering a dump

    killall ruby; \
    dropdb -h localhost -U postgres coursavenue_development; \
    createdb -h localhost -O postgres -U postgres coursavenue_development && \
    psql coursavenue_development -c 'create extension hstore;' -U postgres && \
    pg_restore --host localhost --port 5432 --username "postgres" --dbname "coursavenue_development" --role "udrhnkjoqg1jmn" --no-password  --verbose "/Users/Nima/Downloads/a569.dump"

    pg_restore --host localhost --port 5432 --dbname "coursavenue_development" --role "udrhnkjoqg1jmn" --verbose /Users/Nima/Downloads/a532.dump -U postgres

## Make a dump

    pg_dump --host localhost --port 5432 --username "postgres" --dbname "coursavenue_development" -f 20_fev.tar --format=t

## Restore staging

```shell
$ PGPASSWORD=QP2Qnt2tBGS06FFE58w0RM5j_0 pg_restore --verbose --clean --no-acl --no-owner -h ec2-79-125-105-227.eu-west-1.compute.amazonaws.com -U flqgmxztwjmjvs -d db7jnmndbshr32 -p 5432 XXX.tar
```

# Maintenance

## Run specs without generating coverage

```sh
CI=1 bundle exec rspec spec/
```

## Rubocop
    bundle exec rubocop -Ra
      -R To follow Rails styleguide
      -a to autocorrect

## Brakeman
`bundle exec brakeman -o brakeman-report.html`


## Blog

Restart mysql
`sudo /etc/init.d/mysqld restart

## Delayed::Job

Reinvoke all jobs :
`Delayed::Job.where.not(last_error: nil).each{ |dj| dj.run_at = Time.now; dj.attempts = 0; dj.save! }`

# Ex of `where` with hstore

`User.where("meta_data -> 'subscription_from' LIKE 'newsletter'")`


For CarrierWave ImageOptimizer
brew install optipng jpegoptim

## Weird bug

    undefined method `dependency_digest' for #<Sprockets::StaticAsset:0x007f9c521cb290>

rake tmp:cache:clear
