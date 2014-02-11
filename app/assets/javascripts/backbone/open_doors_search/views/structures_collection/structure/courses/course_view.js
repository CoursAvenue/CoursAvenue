OpenDoorsSearch.module('Views.StructuresCollection.Structure.Courses', function(Module, App, Backbone, Marionette, $, _) {

    Module.CourseView = FilteredSearch.Views.StructuresCollection.Structure.Courses.CourseView.extend({

        itemView: Module.Plannings.PlanningView,
        itemViewContainer: 'tbody',

        initialize: function initialize (options) {
            this.structure_url = options.structure_url;
        },

        itemViewOptions: function itemViewOptions (model, index) {
            var data = this.model.toJSON();
            data.structure_url = this.structure_url;
            return data;
        }

    });
});
