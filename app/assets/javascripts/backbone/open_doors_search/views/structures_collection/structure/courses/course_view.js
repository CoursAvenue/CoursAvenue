OpenDoorsSearch.module('Views.StructuresCollection.Structure.Courses', function(Module, App, Backbone, Marionette, $, _) {

    Module.CourseView = FilteredSearch.Views.StructuresCollection.Structure.Courses.CourseView.extend({

        itemView: Module.Plannings.PlanningView,
        itemViewContainer: 'tbody',

        initialize: function initialize (options) {
            this.structure_url = options.structure_url;
            this.index = options.index;
            this.collection = new Backbone.Collection(_.map(options.model.get("plannings"), function (data) {
                return new Backbone.Model(data);
            }));
            this.collection.each(function(planning) {
                planning.set({registration_url: Routes.new_planning_participation_path(planning.id)});
            });
        },

        itemViewOptions: function itemViewOptions (model, index) {
            return { structure_url: this.structure_url };
        }

    });
});
