FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.CoursesCollectionView = Backbone.Marionette.CompositeView.extend({
        template: 'backbone/templates/courses_collection_view',

        // The "value" has an 's' at the end, that's what the slice is for
        itemView: Views.CourseView,
        itemViewContainer: '[data-type=container]',

        onRender: function() {
            this.$('[data-behavior=tooltip]').tooltip();
        },

        /* when rendering each collection item, we might want to
         * pass in some info from the paginator_ui or something
         * if do we would do it here */
        itemViewOptions: function(model, index) {
            // we could pass some information from the collectionView
            return { index: index };
        }

    });

});
