//= require_self
//= require ./core_ext
//= require_tree ./templates
//= require_tree ./models
//= require_tree ./views
//= require_tree ./routers

// create a marionette app in the global namespace
FilteredSearch = new Backbone.Marionette.Application();

FilteredSearch.module("Models");
FilteredSearch.module("Views");
FilteredSearch.root = 'filtered-search-root';

/* FilteredSearch should only start if it detects
 * an element whose data-type is the same as its
 * root property.
 * @throw the root was found to be non-unique on the page
 * */
FilteredSearch.detectRoot = function() {
  var result = $('[data-type=' + this.root + ']').length;

  if (result > 1) {
    throw {
      message: 'FilteredSearch->detectRoot: ' + FilteredSearch.root + ' element should be unique'
    }
  }

  return result > 0;
}

FilteredSearch.addRegions({
  mainRegion: '#content'
});

FilteredSearch.addInitializer(function(options){
  console.log("FilteredSearch->addInitializer");
});

$(document).ready(function() {
  console.log('EVENT  document->ready');

  /* we only want the filteredsearch on the search page */
  if (FilteredSearch.detectRoot()) {
    FilteredSearch.start({});
  }

});
