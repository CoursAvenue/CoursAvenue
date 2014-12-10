#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'sunspot/solr/tasks'
require File.expand_path('../config/application', __FILE__)

CoursAvenue::Application.load_tasks

Rake::Task["assets:precompile"].enhance do
  `# rm -rf public/assets`
end
