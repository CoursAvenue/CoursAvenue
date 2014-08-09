
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CourseView = Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'course_view',
        childView: Module.Plannings.PlanningView,
        childViewContainer: '[data-type=plannings-container]',
        emptyView: Module.EmptyView,

        modelEvents: {
            'change': 'updatePlannings'
        },

        initialize: function(options) {
            this.model.set('is_last', options.is_last);
            this.model.set('about', options.about);
            this.model.set('about_genre', options.about_genre);
        },

        /* the Course model used here as the composite part is the actual
        * course model in the structure's courses relation. However, the
        * collection of plannings is _not_ part of the structure. This means
        * that the plannings won't automagically update. So we update them
        * ourselves.
        *
        * TODO: clearly plannings should be a relation on Course... it will
        * just take a brief sojourn in serialization hell to get it done.
        * */
        updatePlannings: function updatePlannings (model) {
            this.collection.set(model.changed.plannings);
        },

        onChildviewMouseenter: function onChildviewMouseenter (view, data) {
            this.trigger("mouseenter", data);
        },

        onChildviewMouseleave: function onChildviewMouseleave (view, data) {
            this.trigger("mouseleave", data);
        },

        onAfterShow: function onAfterShow () {
            this.$('[data-toggle=popover]').popover();
        },
    });

}, undefined);
