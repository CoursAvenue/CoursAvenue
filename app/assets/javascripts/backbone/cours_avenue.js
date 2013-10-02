//= require_self
//= require ./core_ext
//= require_tree ./templates
//= require_tree ./models
//= require_tree ./views
//= require_tree ./routers

// create a marionette app in the global namespace
FilteredSearch = new Backbone.Marionette.Application({
  slug: 'filtered-search',
  /* for use in query strings */
  root: function() { return this.slug + '-root'; },
  bootstrap: function() { return this.slug + '-bootstrap'; },

  /* methods for returning the relevant jQuery collections */
  $root: function() {
    return $('[data-type=' + this.root() + ']');
  },
  $bootstrap: function() {
    return $('[data-type=' + this.bootstrap() + ']');
  },

  /* A filteredSearch should only start if it detects
   * an element whose data-type is the same as its
   * root property.
   * @throw the root was found to be non-unique on the page */
  detectRoot: function() {
    var result = this.$root().length;

    if (result > 1) {
      throw {
        message: 'FilteredSearch->detectRoot: ' + this.root() + ' element should be unique'
      }
    }

    return result > 0;
  }

});

FilteredSearch.module("Models");
FilteredSearch.module("Views");

FilteredSearch.addRegions({
  mainRegion: '#filtered-search'
});

FilteredSearch.addInitializer(function(options){
  console.log("FilteredSearch->addInitializer");

  // scrape all the json from the filtered-search-bootstrap
  var bootstrap = this.$bootstrap().map(function() {
    return JSON.parse($(this).text());
  }).get();

  // Create an instance of your class and populate with the models of your entire collection
  var structures = new FilteredSearch.Models.PaginatedCollection(bootstrap);
  var structuresView = new FilteredSearch.Views.PaginatedCollectionView({
    collection: structures
  });

  // Invoke the bootstrap function
  structures.bootstrap();
  FilteredSearch.mainRegion.show(structuresView);
});

$(document).ready(function() {
  console.log('EVENT  document->ready');

  /* we only want the filteredsearch on the search page */
  if (FilteredSearch.detectRoot()) {
    FilteredSearch.start({});
  }

});
