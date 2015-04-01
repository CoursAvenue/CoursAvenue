StructureProfile.module('Views.Structure.Courses.Privates', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PrivateView = StructureProfile.Views.Structure.Courses.CourseView.extend({
        template: Module.templateDirname() + 'private_view',
        childView: Module.Plannings.PlanningView,
        childViewContainer: '[data-type=plannings-container]',
        emptyView: Module.EmptyView,

        courseHovered: function courseHovered (options) {
            var place_ids = [];
            if (this.model.get('home_place')) { place_ids.push(this.model.get('home_place').id); }
            if (this.model.get('place')) { place_ids.push(this.model.get('place').id); }
            this.trigger("mouseenter", { place_ids: _.uniq(place_ids) });
        },

        courseHoveredOut: function courseHoveredOut (options) {
            var place_ids = [];
            if (this.model.get('home_place')) { place_ids.push(this.model.get('home_place').id); }
            if (this.model.get('place')) { place_ids.push(this.model.get('place').id); }
            this.trigger("mouseleave", { place_ids: _.uniq(place_ids) });
        },

        childViewOptions: function childViewOptions (model, index) {
            return {
                course              : this.model.toJSON(),
                is_last             : (index == (this.collection.length - 1)),
                is_first            : (index == 0),
                is_hidden           : (index > 0),
                number_of_other_date: (this.collection.length - 1),
                course_id           : this.model.get('id')
            };
        }
    });

}, undefined);
