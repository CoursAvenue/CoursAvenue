
/* just a basic backbone model */
UserManagement.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.UserProfilesCollection = CoursAvenue.Models.PaginatedCollection.extend({
        model: Models.UserProfile,

        initialize: function (models, options) {
            var self = this;
            // define the server API based on the load-time URI
            this.server_api = this.makeOptionsFromSearch(window.location.search);
            this.currentPage = 1; // we always start from page 1
            this.server_api.page = function () { return self.currentPage; };

            if (this.server_api.sort === undefined) {
                this.server_api.sort = "email";
            }

            if (this.server_api.order === undefined) {
                this.server_api.order = "desc";
            }

            // now write back the server_api so that the search bar is up to date
            // we are passing this.server_api for fun! ^o^ why not?
            if (window.history.pushState) { window.history.pushState({}, "Search Results", this.getQuery()); }

            this.paginator_ui.currentPage = this.server_api.page();

            this.paginator_ui.grandTotal  = (models.length === 0) ? 0 : options.total;
            this.paginator_ui.totalPages  = Math.ceil(this.paginator_ui.grandTotal / this.paginator_ui.perPage);
            this.url.basename         = window.location.toString().split('/');
            this.url.basename.pop();
            this.url.basename         = this.url.basename.join('/');

            this.grandTotal = options.total;

            // determines whether the given selection is a
            // whitelist of records to be changed, or a
            // blacklist of records to be excluded from an update
            this.blacklist = false;
            this.selection_size = 0;
        },

        /* where we can expect to find the resource we seek
         *  TODO this needs to be set on the server side */
        url: {
            resource: '/mes-eleves',
            data_type: '.json'
        },

        /* we are over-writing this method so that */
        // Fetch the default set of models for this collection, resetting the
        // collection when they arrive. If `reset: true` is passed, the response
        // data will be passed through the `reset` method instead of `set`.
        fetch: function(options) {
            options = options ? _.clone(options) : {};
            if (options.parse === void 0) options.parse = true;
            var success = options.success;
            var collection = this;

            /* we want success to save up the results until the job is done */
            options.success = function(resp) {

                /* only set or reset the collection if the work is done */
                if (resp.meta.busy !== "true") {
                    var method = options.reset ? 'reset' : 'set';
                    collection[method](resp, options);
                }

                /* these need to happen every time, so that the poller keeps polling */
                if (success) success(collection, resp, options);
                collection.trigger('sync', collection, resp, options);
            };

            return this.sync('read', this, options);
        },

        parse: function(response) {
            // we did some kind of request, I guess we should update the query
            if (window.history.pushState) { window.history.pushState({}, "Search Results", this.getQuery()); }

            this.grandTotal = response.meta.total;
            this.totalPages = Math.ceil(response.meta.total / this.paginator_ui.perPage);
            this.jobs = response.meta.busy;

            return response.user_profiles;
        },

        paginator_ui: {
            firstPage:   1,
            perPage:     30,
            totalPages:  0,
            grandTotal:  0,
            radius:      2 // determines the behaviour of the ellipsis
        },

        // TODO update the blacklist
        toggleSelected: function (model) {
            // get the desired state of the selected flag
            var selected = (model.get("selected") === true)? "" : true;
            (selected)? this.selection_size += 1 : this.selection_size -= 1;

            model.set("selected", selected);
        },

        // TODO update the blacklist
        selectAll: function () {
            var selection_size = 0;
            this.each(function (model) {
                if (!model.get("selected")) {
                    selection_size += 1;
                    model.set("selected", true);
                }
            });

            this.selection_size += selection_size;
        },

        // TODO update the blacklist
        deselectAll: function () {
            var selection_size = 0;
            this.each(function (model) {
                if (model.get("selected")) {
                    selection_size -= 1;
                    model.set("selected", "");
                }
            });

            this.selection_size += selection_size;
        },

        getSelected: function () {
            return this.where({ selected: true });
        },

        getSelectedCount: function () {
            return this.selection_size;
        },

        /* in addition to selecting the models,
        * set this.deep so that the bulk_action_controller
        * will know to affect all models not marked */
        deepSelect: function () {
            this.blacklist = true;
            this.selection_size = this.grandTotal;
            GLOBAL.flash(this.selection_size + " lignes selectionnées.", 'notice'); // TODO needs the notification object
        },

        clearSelected: function () {
            _.each(this.getSelected(), function (model) {
                model.set("selected", "");
            });

            this.selection_size = 0;
            this.blacklist = false;
        },

        bulkAddTags: function (tags) {
            var models = this.getSelected();

            // when we have deep selection we have to pass in the ids of the
            // models that we _do not_ want to affect
            $.ajax({
                type: "POST",
                url: this.url.basename + '/bulk.json',
                data: {
                    ids: _.pluck(this.getSelected(), 'id'),
                    tags: tags,
                    blacklist: this.blacklist
                }
            });
        },

        // not sure how to implement this in the blacklist mode
        // since we don't have any models off page
        destroySelected: function () {
            var models = this.getSelected();

            _.each(models, function (model) {
                model.destroy();
            });
        }
    });
});
