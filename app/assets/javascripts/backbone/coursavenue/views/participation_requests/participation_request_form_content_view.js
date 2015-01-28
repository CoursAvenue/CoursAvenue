CoursAvenue.module('Views.ParticipationRequests', function(Module, App, Backbone, Marionette, $, _) {
    Module.ParticipationRequestFormContentView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'participation_request_form_content_view',

        events: {
            'change @ui.$course_select'         : 'showAssociatedPlannings',
            'change @ui.$planning_select_input' : 'updateDatePicker'
        },

        ui: {
            '$course_select'                   : 'select[name="participation_request[course_id]"]',
            '$planning_select_wrapper'         : '[data-element=planning-select-wrapper]',
            '$planning_select_input'           : '[data-element=planning-select-wrapper] select',
            '$datepicker_wrapper'              : '[data-element=datepicker-wrapper]',
            '$datepicker_input'                : '[data-element=datepicker-wrapper] input',
            '$start_hour_select_input'         : '[data-element=start-hour-select]',
            '$time_wrapper'                    : '[data-element="time-wrapper"]',
            '$start_minute_select'             : '[data-element="start-minute-select"]',
            '$address_info'                    : '[data-element="address-info"]'
        },

        initialize: function initialize (options) {
            this.model                = options.model; // ParticipationRequest
            this.courses_collection   = options.courses_collection;
            this.trainings_collection = options.trainings_collection;
            this.courses_collection.on('change', this.render.bind(this).debounce(500));
            this.trainings_collection.on('change', this.render.bind(this).debounce(500));
        },

        initializeStartHourSelect: function initializeStartHourSelect () {
            if (!_.isUndefined(this.model.get('start_min'))) {
                _.each(this.ui.$start_minute_select.find('option'), function(option) {
                    if (this.model.get('start_min') == parseInt(option.value, 10)) {
                        option.selected = true;
                    }
                }, this);
            }
            _.each(['06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23'], function(value) {
                var option = $('<option>').attr('value', parseInt(value)).text(value);
                if (this.model.get('start_hour') == parseInt(value, 10)) { option.prop('selected', true); }
                this.ui.$start_hour_select_input.append(option);
            }, this);
        },

        onRender: function onRender () {
            this.initializeStartHourSelect();
            var datepicker_options = {
                format: GLOBAL.DATE_FORMAT,
                weekStart: 1,
                language: 'fr',
                autoclose: true,
                todayHighlight: true,
                startDate: new Date()
            };
            this.ui.$datepicker_input.datepicker(datepicker_options);
            if (this.model.get('course_id')) { this.selectCourse(); }
            if (this.model.get('planning_id')) { this.selectPlanning(); }
        },

        selectPlanning: function selectPlanning () {
            this.ui.$planning_select_input.find('option').removeProp('selected');
            this.ui.$planning_select_input.find('option[value=' + this.model.get('planning_id') + ']').prop('selected', true);
        },
        /*
         * When a user select a course in the select box, we show the associated plannings
         */
        showAssociatedPlannings: function showAssociatedPlannings () {
            var course_id = parseInt(this.ui.$course_select.val());
            this.model.set('course_id', course_id);
            this.selectCourse();
        },

        /*
         * Return course model
         */
        getCurrentCourse: function getCurrentCourse () {
            // Check if the course is in the courses_collection
            var course = this.courses_collection.findWhere({ id: this.model.get('course_id') });
            if (course) { return course; }
            // If it is not, check in the trainings collection
            return this.trainings_collection.findWhere({ id: this.model.get('course_id') });
        },

        /*
         * Return all the plannings of the currently selected course
         */
        getCurrentCoursePlannings: function getCurrentCoursePlannings () {
            return (this.getCurrentCourse() ? this.getCurrentCourse().get('plannings') : []);
        },

        /*
         * Return the currently selected planning
         */
        getCurrentPlanning: function getCurrentPlanning () {
            return _.findWhere(this.getCurrentCoursePlannings(), { id: this.model.get('planning_id') });
        },

        /*
         * Select course in select
         */
        selectCourse: function selectCourse () {
            this.ui.$course_select.find('option').removeProp('selected').removeAttr('selected');
            this.ui.$course_select.find('option[value=' + this.model.get('course_id') + ']').prop('selected', true).attr('selected', true);
            if (this.getCurrentCoursePlannings().length > 0) {
                this.ui.$planning_select_wrapper.slideDown();
                this.ui.$time_wrapper.hide();
            // If it's a private course without
            } else {
                this.ui.$time_wrapper.show();
                this.ui.$planning_select_wrapper.slideUp();
                if (this.getCurrentCourse()) {
                    this.ui.$address_info.text(this.getCurrentCourse().get('course_location'));
                }
            }
            this.populatePlannings();
            if (this.getCurrentCourse().get('db_type') == 'Course::Training') {
                this.ui.$datepicker_wrapper.slideUp();
            } else {
                this.ui.$datepicker_wrapper.slideDown();
            }
        },

        /*
         * Add plannings option to planning select regarding the selected course
         */
        populatePlannings: function populatePlannings () {
            if (! this.model.get('course_id')) { return; }
            var planning_id = this.model.get('planning_id');
            this.ui.$planning_select_input.empty();
            _.each(this.getCurrentCoursePlannings(), function(planning, index) {
                var option = $('<option>').attr('value', planning.id).text(planning.date + ' ' + planning.time_slot);
                if (planning.id == planning_id || (!planning_id && index == 0)) {
                    option.attr('selected', true);
                }
                this.ui.$planning_select_input.append(option);
            }, this);
            this.updateDatePicker();
        },

        /*
         * Set the datepicker to the next possible date
         */
        updateDatePicker: function updateDatePicker () {
            this.model.set('planning_id', parseInt(this.ui.$planning_select_input.val()));
            if (!this.getCurrentPlanning()) {
                this.ui.$datepicker_input.datepicker('update', new Date());
                this.ui.$datepicker_input.datepicker('setDaysOfWeekDisabled', []);
                return;
            }
            // if (!this.model.get('planning_id')) { return; }
            this.ui.$datepicker_input.datepicker('update', this.getCurrentPlanning().next_date);
            // Disable days of week
            var days_of_week = [0,1,2,3,4,5,6];
            days_of_week.splice(days_of_week.indexOf(this.getCurrentPlanning().week_day), 1);
            this.ui.$datepicker_input.datepicker('setDaysOfWeekDisabled', days_of_week);
            this.ui.$address_info.text(this.getCurrentPlanning().address_name);
        },

        serializeData: function serializeData () {
            var courses_open_for_trial = this.courses_collection.select(function(course) { return course.get('is_open_for_trial') == true });
            var courses_without_open_for_trials = this.courses_collection.select(function(course) { return course.get('is_open_for_trial') != true });
            var data = {
                trial_courses_policy: this.model.get('structure').get('trial_courses_policy'),
                courses_open_for_trial: _.invoke(courses_open_for_trial, 'toJSON'),
                courses_without_open_for_trials: _.invoke(courses_without_open_for_trials, 'toJSON'),
                trainings_without_open_for_trials: this.trainings_collection.toJSON()
            };
            return data;
        }
    });
});
