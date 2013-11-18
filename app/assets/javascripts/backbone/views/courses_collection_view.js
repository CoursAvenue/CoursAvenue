FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.CoursesCollectionView = Backbone.Marionette.CompositeView.extend({
        template: 'backbone/templates/courses_collection_view',

        // The "value" has an 's' at the end, that's what the slice is for
        itemView: Views.CourseView,
        itemViewContainer: '[data-type=container]',

        onRender: function() {
            this.$('[data-behavior=tooltip]').tooltip();
        },

        onItemviewSelected: function (data) {
            console.log("onItemView:selected");
            this.trigger('course:selected', data);
        },

        onItemviewDelected: function (data) {
            console.log("onItemView:deselected");
            this.trigger('course:deselected', data);
        },

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        itemViewOptions: function(model, index) {
            // we could pass some information from the collectionView
            return { index: index };
        },

        /* overriding super's showCollection to only show those items that
        * are valid */
        showCollection: function(){
            var self = this;
            var ItemView = this.getItemView();
            this.collection.each(function(item, index){
                if (item.get('name')) {
                    self.addItemView(item, ItemView, index);
                }
            });
        },
    });

});
