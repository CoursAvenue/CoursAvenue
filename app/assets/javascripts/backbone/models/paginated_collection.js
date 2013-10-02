//= require ../models/structure

/* sets up the details specific to coursavenue's API */
FilteredSearch.Models.PaginatedCollection = Backbone.Paginator.requestPager.extend({
  model: FilteredSearch.Models.Structure,
  paginator_core: {
    type: 'GET',
    dataType: 'json',
    url: function() {
      return this.url.basename + this.url.resource + this.url.datatype;
    }
  },
  paginator_ui: {
    firstPage: 0,
    currentPage: 0,
    perPage: 15,
    totalPages: 10
  },
  server_api: {
    'page': function() { return this.currentPage; }
  },

  parse: function(response) {
    console.log('PaginatedCollection->parse');

    return response;
  },

  url: {
    basename: 'http://localhost:3000',
    resource: '/etablissements',
    datatype: '.json'
  }

});

