
StructureProfile.module('Views.Structure.Courses.Plannings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PlanningView = Marionette.ItemView.extend({
        tagName: 'tr',
        template: Module.templateDirname() + 'planning_view',
        className: 'cursor-pointer',
        events: {
            'mouseenter' : 'announceEnter',
            'mouseleave' : 'announceLeave',
            'click'      : 'showRegistrationForm'
        },

        initialize: function initialize (options) {
            this.options = options || {};
            this.options.is_sleeping = window.coursavenue.bootstrap.meta.is_sleeping;
        },

        onRender: function onRender (argument) {
            this.$el.attr('itemscope', true);
            this.$el.attr('itemtype', 'http://data-vocabulary.org/Event');
            if (window.coursavenue.bootstrap.meta.is_sleeping) {
                this.$el.removeClass('cursor-pointer');
            }
        },

        showRegistrationForm: function showRegistrationForm (argument) {
            this.trigger('register', this.model.toJSON());
        },

        announceEnter: function announceEnter (e) {
            $(e.currentTarget).addClass("active");
            if (this.model.get('home_place_id')) {
                this.trigger("mouseenter", { place_id: this.model.get("home_place_id") });
            }
            this.trigger("mouseenter", { place_id: this.model.get("place_id") });
        },

        announceLeave: function announceLeave (e) {
            $(e.currentTarget).removeClass("active");
            this.trigger("mouseleave", { place_id: this.model.get("place_id") });
        },

        serializeData: function serializeData () {
            var attributes = this.model.toJSON();
            _.extend(attributes, this.options);
            return attributes;
        }
    });

}, undefined);
