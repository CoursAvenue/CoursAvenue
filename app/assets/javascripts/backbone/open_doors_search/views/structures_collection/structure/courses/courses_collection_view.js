OpenDoorsSearch.module('Views.StructuresCollection.Structure.Courses', function(Module, App, Backbone, Marionette, $, _) {

    Module.CoursesCollectionView = FilteredSearch.Views.StructuresCollection.Structure.Courses.CoursesCollectionView.extend({
        childView: Module.CourseView,

        childViewOptions: function childViewOptions (model, index) {
            return {
                structure_url: model.toJSON().structure.data_url
            };
        }
    });

});
