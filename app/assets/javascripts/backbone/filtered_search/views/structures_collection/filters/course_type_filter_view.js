
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.CourseTypeFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'course_type_filter_view',

        setup: function setup (data) {
            var self = this;
            _.each(data.course_types, function(course_type) {
                self.activateInput(course_type);
            });
            this.setButtonState();
        },

        ui: {
            '$clear_filter_button' : '[data-behavior=clear-filter]',
            '$clearer'             : '[data-el=clearer]',
        },

        events: {
            'change input': 'announce',
            'click @ui.$clear_filter_button': 'clear'
        },

        announce: function announce (e, data) {
            var course_types = _.map(this.$('[name="course_types[]"]:checked'), function(input){ return input.value });
            this.trigger("filter:level", { 'course_types[]': course_types });
            this.setButtonState(course_types);
        }.debounce(GLOBAL.DEBOUNCE_DELAY),

        /*
         * Set the state of the button, wether or not there are filters or not
         */
        setButtonState: function setButtonState (course_types) {
            course_types = course_types || _.map(this.$('[name="course_types[]"]:checked'), function(input){ return input.value });
            if (course_types.length > 0) {
                this.ui.$clearer.show();
                this.ui.$clear_filter_button.removeClass('btn--gray');
            } else {
                this.ui.$clear_filter_button.addClass('btn--gray');
                this.ui.$clearer.hide();
            }
        },

        activateInput: function activateInput (course_type) {
             var $input = this.$('[value=' + course_type + ']');
            $input.prop('checked', true);
            $input.parent('.btn').addClass('active');
        },
        // Clears all the given filters
        clear: function clear () {
            _.each(this.$('input'), function(input) {
                var $input = $(input);
                $input.prop("checked", false);
                $input.parent('.btn').removeClass('active');
            });
            this.announce();
        }
    });
});
