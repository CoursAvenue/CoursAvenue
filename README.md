# Dependencies / Gems

# For Will_paginate
A custom renderer has been created in lib/

# SCSS
Inuit.css
Compass for mixins

# Add remote branch for Heroku
git remote add heroku git@heroku.com:leboncours.git


# Heroku

[Using Labs: user-env-compile](https://devcenter.heroku.com/articles/labs-user-env-compile#use-case)

    heroku labs:enable user-env-compile -a

# Paperclip

Dependencies: imagemagick

## For Heroku

heroku config:add AWS_BUCKET=bucket_name
heroku config:add AWS_ACCESS_KEY_ID=
heroku config:add AWS_SECRET_ACCESS_KEY=

# Admin
Admin.create!(:email => 'admin@coursmania.com', :password => 'password', :password_confirmation => 'password', first_name: 'Nima', last_name: 'Izadi')

# Solr
https://github.com/sunspot/sunspot#readme
Run local server:
$ rake sunspot:solr:run

Heroku:
Start / Stop :
$ heroku run rake sunspot:solr:start
$ heroku run rake sunspot:solr:stop
Reindex :
$ heroku run rake sunspot:reindex


# Git
List all branches
$ git branch -a
Remove local branch
$ git branch -D branch_name
Remove remote branch
$ git push origin --delete branch_name

# Cities
http://download.geonames.org/export/zip/
