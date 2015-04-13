Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.LayoutsCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'layouts_collection_layout',
        tagName: 'div',
        className: 'text--center',
        childViewContainer: '[data-type=layout]',
        childView: Module.LayoutView,
        // Setting this allows us to send events without a prefix in the childView
        // and to receive them with the prefix in the application.
        // childViewEventPrefix: 'layout',

        initialize: function initialize (options) {
            this.selected_layout = options.collection.findWhere({selected: true});
        },

        onChildviewSelected: function onChildviewSelected (layout_view, params) {
            if (_.isUndefined(this.selected_layout)) {
                this.selected_layout = layout_view.model;
                layout_view.$('img').removeClass('opacity-30');
                this.trigger('layout:selected', params);
            } else {
                // TODO: Remove alerts and permit to change if no edition has been made
                alert('Vous ne pouvez pas changer de modèle');
            }
        }
    });
})
