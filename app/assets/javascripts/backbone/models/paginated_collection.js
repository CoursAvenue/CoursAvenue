/* Sets up the details specific to coursavenue's API */
/* TODO I think it should preload the next and previous pages */
FilteredSearch.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.PaginatedCollection = Backbone.Paginator.requestPager.extend({
        model: Models.Structure,

        /* even if we are bootstrapping, we still want to know the total
        * number of pages and the grandTotal, for display purposes */
        initialize: function (models, options) {
          console.log("PaginatedCollection->initialize");

          this.paginator_ui.grandTotal = options.total;
          this.paginator_ui.totalPages = Math.ceil(options.total / this.paginator_ui.perPage);
        },

        paginator_ui: {
            firstPage:   1,
            currentPage: 1,
            perPage:     15,
            totalPages:  0,
            grandTotal: 0,
            radius: 1 // determines the behaviour of the ellipsis
        },

        server_api: {
            'page': function() { return this.currentPage; }
        },

        parse: function(response) {
            console.log('PaginatedCollection->parse');
            this.paginator_ui.grandTotal = response.meta.total;
            this.paginator_ui.totalPages = Math.ceil(response.meta.total / this.paginator_ui.perPage);

            return response.structures;
        },

        /* the Query methods are for populating anchors */
        previousQuery: function() {
          return this.pageQuery(this.paginator_ui.currentPage - 1);
        },

        nextQuery: function() {
          return this.pageQuery(this.paginator_ui.currentPage + 1);
        },

        currentQuery: function() {
          return this.pageQuery(this.paginator_ui.currentPage);
        },

        pageQuery: function(page) {
          return this.url.resource + '?page=' + page;
        },

        paginator_core: {
            type: 'GET',
            dataType: 'json',
            url: function() {
                return this.url.basename + this.url.resource + this.url.datatype + this.paramString();
            }
        },

        /* where we can expect to find the resource we seek
        *  TODO this will need to be expanded to include all
        *    relevant filters and params */
        url: {
            basename: 'http://www.examples.com',
            resource: '/stuff',
            datatype: '.json',
            params: {
              sort: 'rating_desc'
            }
        },

        paramString: function() {
          var string = "?";

          _.each(_.pairs(this.url.params), function(pair) {
            var key = pair[0],
                value = pair[1];

            string += key + '=' + value + '&';
          });

          return string;
        },

        /* TODO change this method to take a hash of options (a 'configuration object') */
        setUrl: function(options) {
          if (options.basename  != undefined) { this.url.basename  = options.basename; }
          if (options.resource  != undefined) { this.url.resource  = '/' + options.resource; }
          if (options.data_type != undefined) { this.url.data_type = '.' + options.data_type; }
          if (options.params != undefined) { this.url.params = options.params; }
        }
    });
});

// for later
//  address_name=Paris&
//  city=paris&
//  lat=48.8592&
//  lng=2.3417&
//  name=danse&
//  page=2&
//  radius=5&
//  sort=rating_desc
//  &utf8=%E2%9C%93
