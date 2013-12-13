
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
            this.announceBreadcrumb();
        },

        events: {
            'change input': 'announce'
        },

        announce: function (e, data) {
            var course_types = _.map(this.$('[name="course_types[]"]:checked'), function(input){ return input.value });
            this.trigger("filter:level", { 'course_types[]': course_types });
            this.announceBreadcrumb(course_types);
        },

        announceBreadcrumb: function(course_types) {
            course_types = course_types || _.map(this.$('[name="course_types[]"]:checked'), function(input){ return input.value });
            if (course_types.length === 0) {
                this.trigger("filter:breadcrumb:remove", {target: 'course_type'});
            } else {
                this.trigger("filter:breadcrumb:add", {target: 'course_type'});
            }
        },

        activateInput: function(course_type) {
             var $input = this.$('[value=' + course_type + ']');
            $input.prop('checked', true);
            $input.parent('.btn').addClass('active');
        },
        // Clears all the given filters
        clear: function () {
            _.each(this.$('input'), function(input) {
                var $input = $(input);
                $input.prop("checked", false);
                $input.parent('.btn').removeClass('active');
            });
            this.announce();
        }
    });
});
