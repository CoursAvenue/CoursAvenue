
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.CourseTypeFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'course_type_filter_view',

        initialize: function() {
            this.announce = _.debounce(this.announce, 800);
        },

        setup: function (data) {
            var self = this;
            _.each(data.course_types, function(course_type) {
                self.activateInput(course_type);
            });
        },

        events: {
            'change input': 'announce'
        },

        announce: function (e, data) {
            var course_types = _.map(this.$('[name="course_types[]"]:checked'), function(input){ return input.value });
            this.trigger("filter:level", { 'course_types[]': course_types });
        },

        activateInput: function(course_type) {
             var $input = this.$('[value=' + course_type + ']');
            $input.prop('checked', true);
            $input.parent('.btn').addClass('active');
        }
    });
});
