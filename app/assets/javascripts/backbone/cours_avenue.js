//= require_self
//= require ./core_ext
//= require_tree ./templates
//= require_tree ./models
//= require_tree ./views
//= require_tree ./routers

// create a marionette app in the global namespace
MyApp = new Backbone.Marionette.Application();

MyApp.module("Models");
MyApp.module("Views");

MyApp.addRegions({
  mainRegion: '#content'
});

$(document).ready(function() {
  console.log('gosh');
});
