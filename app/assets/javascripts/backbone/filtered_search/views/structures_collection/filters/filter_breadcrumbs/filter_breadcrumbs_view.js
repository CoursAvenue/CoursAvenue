
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters.FilterBreadcrumbs', function(Module, App, Backbone, Marionette, $, _) {

    Module.FilterBreadcrumbsView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'filter_breadcrumbs_view',

        fancy_breadcrumb_names: {},

        initialize: function initialize (options) {
            this.debounced_render = _.debounce(Marionette.ItemView.prototype.render, 500);
            this.breadcrumbs = {};

            if (options && options.fancy_breadcrumb_names) {
                this.fancy_breadcrumb_names = options.fancy_breadcrumb_names;
            }
        },

        render: function render () {
            this.debounced_render();
        },

        ui: {
            '$breadcrumbs': '[data-type=clear]'
        },

        events: {
            'click @ui.$breadcrumbs': 'clear'
        },

        // @data: - hash
        //    target: name of the filter
        //    name
        removeBreadCrumb: function removeBreadCrumb (data) {
            var fancy_name = this.fancy_breadcrumb_names[data.target];

            if (fancy_name) {
                delete this.breadcrumbs[fancy_name];
            }

            this.render();
        },

        onRender: function onRender () {
            this.$('[data-behavior="tooltip"]').tooltip();
        },

        /* for each datum, call addBreadcrumb*/
        addBreadCrumbs: function addBreadCrumbs (data) {
            // we are given data like { 'audience': 1, 'week_days': 1 }
            _.each(data, function (value, key) {
                this.addBreadCrumb({ target: key });
            }.bind(this));
        },

        // @data: - hash
        //    target
        //    name
        addBreadCrumb: function addBreadCrumb (data) {
            this.breadcrumbs[data.target] = {target: data.target};

            this.breadcrumbs[data.target].name = this.fancy_breadcrumb_names[data.target];

            if (data.title)           { this.breadcrumbs[data.target].title = data.title; }
            if (data.additional_info) { this.breadcrumbs[data.target].additional_info = data.additional_info; }

            this.render(); // we debounce this because it could be called many times in a row
        },

        // TODO debounce the removal of filters, so that if a person clear
        // many filters we will only emit one event.
        // TODO OR namespace the events for each filter
        // for now, will namespace, but I can see that being weird
        clear: function clear (e) {
            var data = $(e.currentTarget).data();

            // announce that clearing has happened, and which filter was cleared
            this.trigger('breadcrumbs:clear', data);
            this.trigger('breadcrumbs:clear:' + data.target, data);

            this.removeBreadCrumb(data);
            this.render();
        },

        // we only want to serialize each breadcrumb once, though they may appear multiple times
        serializeData: function serializeData () {
            // breadcrumbs is like { week_days: 'Date', age_max: 'Audience', age_min: 'Audience' }
            // but we don't want "Audience" in there twice. This reduce uniq's the object by value
            this.breadcrumbs = _.reduce(this.breadcrumbs, function (memo, v, k) {
                if (memo[v.name]) {
                    return memo;
                }

                memo[v.name] = v;
                return memo;
            }, {});

            return {
                breadcrumbs: this.breadcrumbs
            }
        }
    });
});
