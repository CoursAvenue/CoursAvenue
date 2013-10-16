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
            'click': 'resolveClick',
            'mouseenter': 'selectStructure',
            'mouseleave': 'deselectStructure'
        },

        /* TODO this is unfortunate, for some reason I can only pass
        * 'this' through the trigger. I think it is because the event
        * is being passed on by the collectionView. This shouldn't
        * be too hard to fix, but I will leave it for now. */
        selectStructure: function (e) {
            this.trigger('selected', this);
        },

        deselectStructure: function (e) {
            this.trigger('deselected', this);
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
