CoursAvenue.module('Views.ParticipationRequests', function(Module, App, Backbone, Marionette, $, _) {
    Module.ParticipationRequestFormContentView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'participation_request_form_content_view',

        events: {
            'change @ui.$course_select'         : 'showAssociatedPlannings',
            'change @ui.$planning_select_input' : 'updateDatePicker',
            'change @ui.$choose_place_select'   : 'showStudentAddressFields'
        },

        ui: {
            '$course_select'                   : 'select[name="participation_request[course_id]"]',
            '$planning_select_wrapper'         : '[data-element=planning-select-wrapper]',
            '$planning_select_input'           : '[data-element=planning-select-wrapper] select',
            '$datepicker_wrapper'              : '[data-element=datepicker-wrapper]',
            '$datepicker_input'                : '[data-element=datepicker-wrapper] input',
            '$start_hour_select_input'         : '[data-element=start-hour-select]',
            '$time_wrapper'                    : '[data-element=time-wrapper]',
            '$start_minute_select'             : '[data-element=start-minute-select]',
            '$address_info_wrapper'            : '[data-element=address-info-wrapper]',
            '$address_info'                    : '[data-element=address-info]',
            '$student_address_wrapper'         : '[data-element=student-address-wrapper]',
            '$student_address_input'           : '[data-element=student-address-input]',
            '$choose_place_select'             : '[data-element=choose-place-select]'
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
                if (this.model.get('start_hour')) {
                    if (this.model.get('start_hour') == parseInt(value, 10)) { option.prop('selected', true); }
                } else if (parseInt(value, 10) == 10) {
                    option.prop('selected', true);
                }
                this.ui.$start_hour_select_input.append(option);
            }, this);
        },

        onRender: function onRender () {
            this.initializeStartHourSelect();
            var datepicker_options = {
                format: COURSAVENUE.constants.DATE_FORMAT,
                weekStart: 1,
                language: 'fr',
                autoclose: true,
                todayHighlight: true,
                startDate: new Date()
            };
            this.ui.$datepicker_input.datepicker(datepicker_options);
            if (this.model.get('course_id')) { this.selectCourse(); }
            if (this.model.get('planning_id')) { this.selectPlanning(); }
            // Wait in order that everything is in the dom
            setTimeout(function() {
                this.$('[data-behavior=city-autocomplete]').cityAutocomplete()
            }.bind(this), 50)
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
            if (_.isNaN(course_id)) {
                this.model.set('course_id', null);
                this.hideAllFields();
            } else {
                this.model.set('course_id', course_id);
                this.model.set('course_type', this.getCurrentCourse().get('db_type'));
                this.selectCourse();
            }
        },

        /*
         * Hide fields if they were opened and trigger event to tell that the course has been deselected
         */
        hideAllFields: function hideAllFields () {
            this.ui.$address_info_wrapper.slideUp();
            this.ui.$planning_select_wrapper.slideUp();
            this.ui.$datepicker_wrapper.slideUp();
            this.ui.$student_address_wrapper.slideUp();
            this.hideStudentAddressWrapper();
            this.trigger('participation_request:course:deselected');
        },

        /*
         * We have specific methods to show and hide student address wrapper because we want to
         * set the hidden input to true or false. It will help to validate the model
         */
        hideStudentAddressWrapper: function hideStudentAddressWrapper () {
            this.ui.$student_address_input.val(false);
            this.ui.$student_address_wrapper.slideUp();
        },

        showStudentAddressWrapper: function showStudentAddressWrapper () {
            this.ui.$student_address_input.val(true);
            this.ui.$student_address_wrapper.slideDown();
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
            // If it's a private course
            if (this.getCurrentCourse().get('db_type') == 'Course::Private' || this.getCurrentCoursePlannings() == 0) {
                this.ui.$time_wrapper.show();
                this.ui.$planning_select_wrapper.slideUp();
            } else {
                this.ui.$planning_select_wrapper.slideDown();
                this.ui.$time_wrapper.hide();
            }
            this.populatePlannings();
            this.updateAddressField();
            if (this.getCurrentCourse().get('db_type') == 'Course::Training') {
                this.ui.$datepicker_wrapper.slideUp();
            } else {
                this.ui.$datepicker_wrapper.slideDown();
            }
            this.model.set('course_type', this.getCurrentCourse().get('db_type'));
            // TODO: Refactor this
            // This is ugly, I know.
            // Delay trigger in order to be sure that the participation request participants receive the event.
            // To try without the delay, try clicking on the "m'inscrire" links on the page, not on the upper form.
            setTimeout(function() {
                this.trigger('participation_request:course:selected', this.getCurrentCourse().toJSON());
            }.bind(this), 50);
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

        showStudentAddressFields: function showStudentAddressFields () {
            if (this.ui.$choose_place_select.val() == 'at_home') {
                this.showStudentAddressWrapper();
            } else {
                this.hideStudentAddressWrapper();
            }
        },
        /*
         * If there is only one address, we show it
         * If the course is at student home, we show a form
         * If the student can choose between his home and an address, we show a dropdown
         */
        updateAddressField: function updateAddressField () {
            var address_with_info;
            if (!this.getCurrentCourse()) { return; }

            // Hide everything in case some stuff was visible
            this.ui.$address_info_wrapper.show();
            this.ui.$choose_place_select.hide();
            this.ui.$address_info.hide();
            // If teaches at home AND has a place, show select box
            if (this.getCurrentCourse().get('teaches_at_home') &&
                this.getCurrentCourse().get('place')) {
                var teacher_place_option = this.ui.$choose_place_select.find('[data-option=teachers-place]');
                this.ui.$choose_place_select.show();
                teacher_place_option.text('Chez le professeur (' +  this.getCurrentCourse().get('place').address + ')');
                teacher_place_option.val(this.getCurrentCourse().get('place').id);
                this.hideStudentAddressWrapper();
            // If teachers at home but DO NOT have a place, show address form
            } else if (this.getCurrentCourse().get('teaches_at_home') || (this.getCurrentPlanning() && this.getCurrentPlanning().teaches_at_home)) {
                var address = (this.getCurrentPlanning() ? this.getCurrentPlanning().address : this.getCurrentCourse().get('course_location'));
                this.ui.$address_info.show().text('À votre domicile').attr('data-content', address);
                this.ui.$address_info.parent().addClass('text-ellipsis');
                this.showStudentAddressWrapper();
            // Else, show the address
            } else {
                this.hideStudentAddressWrapper();
                var address = '';
                if (this.getCurrentCoursePlannings().length > 0) {
                  address           = this.getCurrentPlanning().address;
                  address_with_info = this.getCurrentPlanning().address_with_info;
                } else if (this.getCurrentCourse()) {
                  address = this.getCurrentCourse().get('course_location');
                }
                this.ui.$address_info.parent().addClass('text-ellipsis');
                this.ui.$address_info.show().text(address)
                                            .attr('data-content', address_with_info);
            }
        },

        /*
         * Set the datepicker to the next possible date
         */
        updateDatePicker: function updateDatePicker () {
            this.model.set('planning_id', parseInt(this.ui.$planning_select_input.val()));
            if (!this.getCurrentPlanning()) {
                this.ui.$datepicker_input.datepicker('update', moment().add(7, 'days').toDate());
                this.ui.$datepicker_input.datepicker('setDaysOfWeekDisabled', []);
                return;
            }
            var formatted_date = moment(this.getCurrentPlanning().next_date, "DD/MM/YYYY"); //.format(COURSAVENUE.constants.MOMENT_DATE_FORMAT);
            this.ui.$datepicker_input.datepicker('update', formatted_date.toDate());
            // Disable days of week
            var days_of_week = [0,1,2,3,4,5,6];
            if (this.getCurrentCourse().get('db_type') == 'Course::Private') {
                _.each(this.getCurrentCourse().get('plannings'), function(planning) {
                    if (days_of_week.indexOf(planning.week_day) != -1) {
                        days_of_week.splice(days_of_week.indexOf(planning.week_day), 1);
                    }
                });
            } else {
                days_of_week.splice(days_of_week.indexOf(this.getCurrentPlanning().week_day), 1);
            }
            this.ui.$datepicker_input.datepicker('setDaysOfWeekDisabled', days_of_week);
            this.updateAddressField();
        },

        serializeData: function serializeData () {
            var courses_open_for_trial = this.courses_collection.select(function(course) { return course.get('is_open_for_trial') == true });
            var courses_without_open_for_trials = this.courses_collection.select(function(course) { return course.get('is_open_for_trial') != true });
            var data = {
                trial_courses_policy             : this.model.get('structure').get('trial_courses_policy'),
                courses_open_for_trial           : _.invoke(courses_open_for_trial, 'toJSON'),
                courses_without_open_for_trials  : _.invoke(courses_without_open_for_trials, 'toJSON'),
                trainings_without_open_for_trials: this.trainings_collection.toJSON(),
                cid                              : this.cid
            };
            return data;
        }
    });
});
