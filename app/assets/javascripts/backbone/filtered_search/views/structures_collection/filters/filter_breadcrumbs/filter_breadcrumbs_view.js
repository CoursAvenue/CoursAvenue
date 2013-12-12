
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters.FilterBreadcrumbs', function(Module, App, Backbone, Marionette, $, _) {

    Module.FilterBreadcrumbsView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'filter_breadcrumbs_view',

        ui: {
            '$breadcrumbs': '[data-trigger=clear]'
        },

        events: {
            'click @ui.$breadcrumbs': 'clear'
        },

        // TODO debounce the removal of filters, so that if a person clear
        // many filters we will only emit one event.
        // TODO OR namespace the events for each filter
        // for now, will namespace, but I can see that being weird
        clear: function (e) {
            var data = $(e.currentTarget).data();
            this.trigger('breadcrumbs:clear:' + data.target, data.value);
            this.$el.find(e.currentTarget).remove();
        }
    });
});
