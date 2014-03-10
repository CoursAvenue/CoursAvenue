
StructureProfile.module('Views.Structure.Courses.Plannings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PlanningView = Marionette.ItemView.extend({
        tagName: 'tr',
        template: Module.templateDirname() + 'planning_view',

        events: {
            'mouseenter': 'announceEnter',
            'mouseleave': 'announceLeave'
        },

        /* ***
         * Course is an itemview, but its Collection is not defined explicitly.
        * In this case, the events fire from the Course get are still received
        * by the Collection, and then emitted again with the itemview prefix.
        * The result is that the View Module will get an event like `itemview:course:hovered`.
        * This isn't a great default behavior for a standalone itemview, I'd
        * rather the Module receive just `course:hovered`. At the same time, if
        * things are starting to get complicated we will no doubt eventually
        * implement a Courses collection view explicitly, and in that case we
        * can fire whatever events we want. */
        announceEnter: function (e) {
            $(e.currentTarget).addClass("active");
            this.trigger("course:mouseenter");
        },

        announceLeave: function (e) {
            $(e.currentTarget).removeClass("active");
            this.trigger("course:mouseleave");
        }
    });

}, undefined);
