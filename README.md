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

# ActiveAdmin
AdminUser.create!(:email => 'admin@leboncours.com', :password => 'password', :password_confirmation => 'password')

# Solr
https://github.com/sunspot/sunspot#readme
Run local server: rake sunspot:solr:run

Heroku:
Start / Stop :
> heroku run rake sunspot:solr:start
> heroku run rake sunspot:solr:stop
Reindex :
> heroku run rake sunspot:reindex
