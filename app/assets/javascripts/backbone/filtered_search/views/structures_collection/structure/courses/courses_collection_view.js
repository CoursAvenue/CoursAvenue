FilteredSearch.module('Views.StructuresCollection.Structure.Courses', function(Module, App, Backbone, Marionette, $, _) {

    Module.CoursesCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'courses_collection_view',

        // The "value" has an 's' at the end, that's what the slice is for
        childView: Module.CourseView,
        childViewContainer: '[data-type=container]',

        onChildviewToggleSelected: function (view, data) {
            var places = view.model.get('structure').get('places'),
                keys = places.findWhere({ id: data.place_id });

            this.trigger('course:focus', { keys: keys });
        },

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        childViewOptions: function(model, index) {
            // we could pass some information from the collectionView
            return { index: index };
        },

        /* overriding super's showCollection to only show those items that
        * are valid */
        showCollection: function(){
            var self = this;
            var ItemView = this.getChildView();
            this.collection.each(function(item, index){
                if (item.get('name')) {
                    self.addChild(item, ItemView, index);
                }
            });
        },
    });

});
