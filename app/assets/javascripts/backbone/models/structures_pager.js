FilteredSearch.Models.Structure = Backbone.Model.extend({});

FilteredSearch.Models.StructuresPager = Backbone.Paginator.requestPager.extend({
  model: FilteredSearch.Models.Structure,
  paginator_core: {
    type: 'GET',
    dataType: 'json',
    url: 'http://localhost:3000/etablissements.json'
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
    return response;
  }
});

// for later
//  address_name=Paris&
//  city=paris&
//  lat=48.8592&
//  lng=2.3417&
//  name=danse&
//  page=2&
//  radius=5&
//  sort=rating_desc&utf8=%E2%9C%93

