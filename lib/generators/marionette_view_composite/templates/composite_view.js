/* a view for presenting a backbone.paginator collection, and for presenting and handling
 * its pagination UI element */

<%= app %>.module('Views<%= (!namespace.blank? ? "." + namespace : "") %>.<%= collection_name(name) %>', function(Module, App, Backbone, Marionette, $, _) {
    Module.<%= collection_view_name(name) %> = Backbone.Marionette.<%= backbone_class %>.extend({
        template: Module.templateDirname() + '<%= name.underscore.pluralize %>_collection_view',
        itemView: Module.<%= name %>.<%= item_view_name(name) %>,
        itemViewContainer: 'tbody',
        className: '<%= collection_name(name).underscore.gsub(/_/, "-") %>',

        /* TODO choose a model to represent the composite portion, if you want */
        model: <%= app %>.Models.SomeModel,

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        /* remember that itemViews are constructed and destroyed more often
        * than the corresponding models */
        itemViewOptions: function(model, index) {
            return { };
        },

        /* override inherited method */
        announce<%= name.pluralize %>Updated: function () {
            var data = this.collection;

            this.trigger('<%= name.underscore.gsub(/_/, ":").pluralize %>:updated');

        },
    });
});

