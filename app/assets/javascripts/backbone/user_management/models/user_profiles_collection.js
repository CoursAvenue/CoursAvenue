
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
            this.all_ids    = options.ids;

            this.selected_ids    = [];
            this.setSelectedCount(0);
            this.deep_select     = false;
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

            // when we get back a filtered result set, we will want to set the selection's
            // length to represent the intersection between records that are selected
            // and records that appear in the filtered result set
            var result_set        = response.meta.ids;
            var visible_selection = _.intersection(result_set, this.selected_ids);

            this.setSelectedCount(visible_selection.length);

            return response.user_profiles;
        },

        paginator_ui: {
            firstPage:   1,
            perPage:     30,
            totalPages:  0,
            grandTotal:  0,
            radius:      2 // determines the behaviour of the ellipsis
        },

        /* returns true if the given model is in the current list */
        isChecked: function (model) {
            return (this.selected_ids.indexOf(model.get("id")) != -1);
        },

        /* DEEP SELECT */
        /* deep select is implemented by having an array of ids. When
         * a user chooses deep select, we replace the array of ids with
         * an array of all ids fetched from the server */
        /* any time we add or remove a model id from the list, we also
         * fire a change event, to capture this */

        /* add or remove the given model from the list */
        toggleSelected: function (model) {
            // get the desired state of the selected flag
            var id = model.get("id");
            var index = this.selected_ids.indexOf(id);

            if (index == -1) {
                this.addSelected(id);
                model.trigger("change", { changed: { selected: "true" }});
            } else {
                this.removeSelectedAt(index);
                model.trigger("change", { changed: { selected: "" }});
            }

        },

        /* add the current page of ids to the list */
        selectAll: function () {
            var selected_ids = this.selected_ids;
            var added = 0;

            this.each(function (model) {
                var id = model.get("id");
                var index = selected_ids.indexOf(id);

                if (index == -1) {
                    selected_ids.push(id)
                    added += 1;
                    model.trigger("change", { changed: { selected: "true" }});
                }
            });

            // set the count all at once to avoid a huge emission of events
            // TODO maybe solve this with debounce later???
            this.setSelectedCount(this.selected_length + added);
        },

        /* remove the current page of ids to the list */
        deselectAll: function () {
            var selected_ids = this.selected_ids;
            var removed = 0;

            this.each(function (model) {
                var id    = model.get("id");
                var index = selected_ids.indexOf(id);

                if (index > -1) {
                    selected_ids.splice(index, 1);
                    removed += 1;
                    model.trigger("change", { changed: { selected: "" }});
                }
            });

            // set the count all at once to avoid a huge emission of events
            // TODO maybe solve this with debounce later???
            this.setSelectedCount(this.selected_length - removed);
        },

        getSelected: function () {
            return this.selected_ids;
        },

        // the length of the selection is not always the number of
        // ids in it. Sometimes some of the ids may be hidden behind
        // a filter
        setSelectedCount: function (length) {
            this.selected_length = length;

            this.trigger("selection:counts", {
                count: this.getSelectedCount(),
                total: this.grandTotal,
                deep:  this.isDeep()
            });
        },

        getSelectedCount: function () {
            return this.selected_length;
        },

        addSelected: function (id) {
            this.selected_ids.push(id);
            this.setSelectedCount(this.selected_length + 1);
        },

        removeSelectedAt: function (index) {
            this.selected_ids.splice(index, 1);
            this.setSelectedCount(this.selected_length - 1);
        },

        /* in addition to selecting the models,
        * set this.deep so that the bulk_action_controller
        * will know to affect all models not marked */
        deepSelect: function () {
            this.deep_select = true;
            this.selectAll(); // to trigger the change

            var self = this;

            return $.ajax({
                type: "GET",
                url: this.url.basename + '/bulk/new.json',
                data: this.server_api,
                success: function (data) {
                    self.selected_ids    = data.ids;
                    self.setSelectedCount(data.ids.length);

                    GLOBAL.flash(self.getSelectedCount() + " lignes selectionnées.", 'notice'); // TODO needs the notification object
                }
            });
        },

        clearSelected: function () {
            this.deep_select = false;
            this.deselectAll(); // to trigger the change

            this.selected_ids    = [];
            this.setSelectedCount(0);
        },

        isDeep: function () {
            return this.deep_select;
        },

        bulkAddTags: function (tags) {
            var ids = this.getSelected();

            // when we have deep selection we have to pass in the ids of the
            // models that we _do not_ want to affect
            return $.ajax({
                type: "POST",
                url: this.url.basename + '/bulk.json',
                data: {
                    ids: ids,
                    tags: tags,
                    search: this.server_api
                }
            });
        },

        // we need to implement this to work with deep select
        // probably we will end up sending the bulk delete message
        destroySelected: function () {
            // TODO
        }
    });
});
