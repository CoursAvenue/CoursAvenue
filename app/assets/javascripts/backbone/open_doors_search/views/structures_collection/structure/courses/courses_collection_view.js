OpenDoorsSearch.module('Views.StructuresCollection.Structure.Courses', function(Module, App, Backbone, Marionette, $, _) {

    Module.CoursesCollectionView = FilteredSearch.Views.StructuresCollection.Structure.Courses.CoursesCollectionView.extend({
        itemView: Module.CourseView,

        itemViewOptions: function itemViewOptions (model, index) {
            return {
                structure_url: model.toJSON().structure.data_url
            };
        }
    });

});
