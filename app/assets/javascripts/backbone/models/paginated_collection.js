/* Sets up the details specific to coursavenue's API */
FilteredSearch.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.PaginatedCollection = Backbone.Paginator.requestPager.extend({
        model: Models.Structure,

        /* even if we are bootstrapping, we still want to know the total
        * number of pages */
        initialize: function (models, options) {
          console.log("PaginatedCollection->initialize");

          this.paginator_ui.totalPages = options.total;
        },

        paginator_core: {
            type: 'GET',
            dataType: 'json',
            url: function() {
                return this.url.basename + this.url.resource + this.url.datatype;
            }
        },
        paginator_ui: {
            firstPage:   1,
            currentPage: 1,
            perPage:     15,
            totalPages:  3,
            /* these methods return the url of the query for the
            * previous, next, or current page. I'm not really sure
            * this is necessary... the idea was to have nice anchors
            * with useful URLs even though clicking on them will just
            * fire events. Maybe that is good? */
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
              return this.url.resource + this.url.datatype + '?page=' + page;
            }
        },
        server_api: {
            'page': function() { return this.currentPage; }
        },

        parse: function(response) {
            console.log('PaginatedCollection->parse');
            this.paginator_ui.totalPages = Math.ceil(response.meta.total / this.perPage);

            return response.structures;
        },

        url: {
            basename: 'http://www.examples.com',
            resource: '/stuff',
            datatype: '.json'
        },

        setUrl: function(basename, resource, data_type) {
            if (basename  != undefined) { this.url.basename  = basename; }
            if (resource  != undefined) { this.url.resource  = '/' + resource; }
            if (data_type != undefined) { this.url.data_type = '.' + data_type; }
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
//  sort=rating_desc&utf8=%E2%9C%93
