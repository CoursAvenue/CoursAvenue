/* just a basic marionette view */
OpenDoorsSearch.module('Views.StructuresCollection.Structure.Courses.Plannings', function(Module, App, Backbone, Marionette, $, _) {

    Module.PlanningView = FilteredSearch.Views.StructuresCollection.Structure.Courses.Plannings.PlanningView.extend({
        template: Module.templateDirname() + "planning_view",

        initialize: function initialize (options) {
            this.structure_url = options.structure_url;
        },

        serializeData: function serializeData () {
            var data = this.model.toJSON();
            data.structure_url = this.structure_url;
            return data;
        }
    });
});
