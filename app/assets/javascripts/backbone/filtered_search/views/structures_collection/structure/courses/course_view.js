/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Structure.Courses', function(Module, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Module.CourseView = Backbone.Marionette.CompositeView.extend({
        template:  Module.templateDirname() + "course_view",
        className: "push-half--top soft-half--top bordered--top",
        childView: Module.Plannings.PlanningView,

        childViewContainer: 'tbody',

        initialize: function(options){
            this.index = options.index;
            this.collection = new Backbone.Collection(_.map(options.model.get("plannings"), function (data) {
                return new Backbone.Model(data);
            }));
        },

        onChildviewToggleSelected: function (view, data) {
            this.trigger('toggleSelected', data);
        },

        onRender: function() {
            if (this.index == 0) {
                this.$el.removeClass("bordered--top soft-half--top");
            }
        },
    });
});
