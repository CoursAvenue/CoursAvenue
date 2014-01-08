
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.InfiniteScrollButtonView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'infinite_scroll_button_view',
        className: 'soft-half--sides',

        /* the pagination tool forwards all events, since it has
        * no idea what it is paginating */
        events: {
            'click .btn': 'next',
        },

        next: function (e) {
            e.preventDefault();
            this.trigger('pagination:next', e);

            return false;
        }
    });
});
