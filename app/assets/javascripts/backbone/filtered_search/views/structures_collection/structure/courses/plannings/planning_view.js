/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Structure.Courses.Plannings', function(Module, App, Backbone, Marionette, $, _) {

    /* views here temporarily to get this all all started */
    Module.PlanningView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + "planning_view",
        tagName: 'tr',
        attributes: {
            'data-type': 'line-item'
        },

        events: {
            'mouseenter': 'toggleSelected',
            'mouseleave': 'toggleSelected',
        },

        toggleSelected: function (e) {
            $(e.currentTarget).toggleClass('active');
            this.trigger('toggleSelected', this.model.toJSON());
        }
    });
});
