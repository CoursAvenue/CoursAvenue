# Production & Staging environment

[Some heroku docs](https://devcenter.heroku.com/articles/multiple-environments)

## Production

## Staging

$ git push staging master
$ heroku run rake db:migrate --remote staging
$ heroku ps --remote staging

### Pushing local branch to heroku staging
$ git push staging feature_branch:master

### Rbenv & Pow

\# ~/.powconfig
`export PATH=$(rbenv root)/shims:$(rbenv root)/bin:$PATH`

## Dependencies / Gems

### For Will_paginate
A custom renderer has been created in lib/

### SCSS
Inuit.css
Compass for mixins

### Add remote branch for Heroku
`git remote add heroku git@heroku.com:leboncours.git`


### Heroku

[Using Labs: user-env-compile](https://devcenter.heroku.com/articles/labs-user-env-compile#use-case)

    heroku labs:enable user-env-compile -a

### Paperclip

Dependencies: imagemagick

#### Reprocessing images
h run rake paperclip:refresh CLASS=Course

### For Heroku

`heroku config:add AWS_BUCKET=bucket_name`
`heroku config:add AWS_ACCESS_KEY_ID=`
`heroku config:add AWS_SECRET_ACCESS_KEY=`

### [Solr sunspot](https://github.com/sunspot/sunspot#readme)
Commands
`rake sunspot:solr:run`

On heroku
`heroku run rake sunspot:solr:start`
`heroku run rake sunspot:solr:stop`
`heroku run rake sunspot:reindex`


### Git
Remove local branch
`git branch -D branch_name`
Remove remote branch
`git push origin --delete branch_name`

### Cities
http://download.geonames.org/export/zip/

### Sitemap

`RAILS_ENV=production rake sitemap:create`

### I18n

Exporting translations:
`rake i18n:js:export`

### Tests
rake db:test:clone
RAILS_ENV=test rake sunspot:solr:start
$ rspec spec

# Recovering a dump
killall ruby; dropdb -h localhost -U postgres coursavenue_development; createdb -h localhost -O postgres -U postgres coursavenue_development && pg_restore --host localhost --port 5432 --username "postgres" --dbname "coursavenue_development" --role "qjppevpnykjrmw" --no-password  --verbose "/Users/Nima/Downloads/a184.dump"; zeus start

# Make a dump
pg_dump --host localhost --port 5432 --username "postgres" --dbname "coursavenue_development" -f 19_oct.tar --format=t
