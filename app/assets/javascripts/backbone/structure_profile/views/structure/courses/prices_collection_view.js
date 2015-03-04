
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PricesCollectionView = Marionette.CompositeView.extend({
        childView: Module.PriceView,
        template: Module.templateDirname() + 'prices_collection_view',
        childViewContainer: '[data-type=container]',

        initialize: function initialize (options) {
            this.options = options;
        },

        serializeData: function serializeData (model, index) {
            return {
                has_no_prices: (this.collection.length == 0),
                about_genre  : this.options.about_genre,
                about        : this.options.about
            };
        },
    });
});
