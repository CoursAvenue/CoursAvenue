CoursAvenue.module('Pro.ParticipationRequests.Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.ParticipationRequestFormView = Backbone.Marionette.ItemView.extend({

        events: {
            'change @ui.$course_select': 'courseChanged',
            'change @ui.$planning_select': 'planningChanged'
        },

        ui: {
          '$course_select'     : '[name="participation_request[course_id]"]',
          '$planning_select'   : '[name="participation_request[planning_id]"]',
          '$datepicker'        : '[name="participation_request[date]"]',
          '$datepicker_wrapper': '[data-type=datepicker-wrapper]',
          '$address_container' : '[data-type=address-name]'
        },

        initialize: function initialize (options) {
            _.bindAll(this, 'courseChanged', 'planningChanged');
            this.bindUIElements();
            this.courses_collection   = courses_collection;
            this.selected_course_id   = options.selected_course_id;
            this.selected_planning_id = options.selected_planning_id;
            this.current_plannings    = this.courses_collection.findWhere({ id: this.selected_course_id }).get('plannings');
            this.planningChanged();
        },

        courseChanged: function courseChanged () {
            this.selected_course_id = parseInt(this.ui.$course_select.val(), 10);
            this.current_plannings  = this.courses_collection.findWhere({ id: this.selected_course_id }).get('plannings');
            this.populateWithNewPlannings();
        },

        populateWithNewPlannings: function populateWithNewPlannings () {
            if (this.getCurrentCourse().get('type') == 'Stage') {
                this.ui.$datepicker_wrapper.slideUp();
            } else {
                this.ui.$datepicker_wrapper.slideDown();
            }
            this.ui.$planning_select.empty();
            _.each(this.current_plannings, function(planning, index) {
                var option = $('<option>').attr('value', planning.id).text(planning.date + ' ' + planning.time_slot);
                if (index == 0) { option.attr('selected', true); }
                this.ui.$planning_select.append(option);
            }, this);
            this.selected_planning_id = null;
            this.planningChanged();
        },

        planningChanged: function planningChanged () {
            if (parseInt(this.selected_planning_id, 10) == parseInt(this.ui.$planning_select.val(), 10)) {
                return;
            }
            this.selected_planning_id = parseInt(this.ui.$planning_select.val(), 10);
            var selected_planning = this.getCurrentPlanning();
            // Update datepicker, only if it is not the planning
            // Disable days of week
            var days_of_week = [0,1,2,3,4,5,6];
            days_of_week.splice(days_of_week.indexOf(selected_planning.week_day), 1);
            this.ui.$datepicker.datepicker('setDaysOfWeekDisabled', days_of_week);
            this.ui.$address_container.text(selected_planning.address_name);
            this.ui.$address_container.data('content', selected_planning.address_with_info);
            currently_selected_date = this.ui.$datepicker.datepicker('getDate');
            if (currently_selected_date.getDay() != selected_planning.week_day) {
                this.ui.$datepicker.datepicker('update', selected_planning.next_date);
            }
        },

        getCurrentPlanning: function getCurrentPlanning () {
            return _.find(this.current_plannings, function(planning) {
                return planning.id == this.selected_planning_id;
            }.bind(this));
        },

        getCurrentCourse: function getCurrentCourse () {
            return this.courses_collection.findWhere({ id: this.selected_course_id });
        }
    });
});
