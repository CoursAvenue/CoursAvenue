/* just a basic marionette view */
FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {
    Views.StructureView = Backbone.Marionette.ItemView.extend({
        template: 'backbone/templates/structure_view',

        tagName: 'li',
        className: 'one-whole course-element',
        attributes: {
            'data-type': 'structure-element'
        },

        initialize: function(options) {
            console.log("StructureView->initialize");

            this.$el.data('url', options.model.get('data_url'));
        },

        events: {
            'click': 'resolveClick'
        },

        resolveClick: function (event) {
            if (event.target.nodeName !== 'A') {
                if (event.metaKey || event.ctrlKey) {
                    window.open(this.model.get('data_url'));
                } else {
                    window.location = this.model.get('data_url');
                }
                return false;
            }
        }

    });
});
