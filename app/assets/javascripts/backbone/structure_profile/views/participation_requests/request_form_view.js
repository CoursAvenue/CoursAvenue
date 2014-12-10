StructureProfile.module('Views.ParticipationRequests', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.RequestFormView = Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'request_form_view',
        message_failed_to_send_template: Module.templateDirname() + 'message_failed_to_send',
        className: 'panel center-block push--bottom',

        events: {
            'click'                             : 'trackEvent',
            'submit form'                       : 'submitForm',
            'change @ui.$course_select'         : 'showAssociatedPlannings',
            'change @ui.$planning_select_input' : 'updateDatePicker',
            'change [name=request_type]'        : 'toggleRequestType',
            'click [data-behavior=show-phone-numbers]': 'showPhoneNumbers'
        },

        ui: {
            '$course_select'                   : 'select[name=course_id]',
            '$planning_select_wrapper'         : '[data-element=planning-select-wrapper]',
            '$planning_select_input'           : '[data-element=planning-select-wrapper] select',
            '$datepicker_wrapper'              : '[data-element=datepicker-wrapper]',
            '$datepicker_input'                : '[data-element=datepicker-wrapper] input',
            '$start_hour_select_input'         : '[data-element=start-hour-select]',
            '$time_wrapper'                    : '[data-element="time-wrapper"]',
            '$booking_request_type_wrapper'    : '[data-type=booking-request-type-wrapper]',
            '$information_request_type_wrapper': '[data-type=information-request-type-wrapper]',
            '$request_type_labels'             : '[data-behavior=toggle-type]',
            '$request_type_inputs'             : '[data-behavior=toggle-type] input',
            '$address_info'                    : '[data-element="address-info"]'
        },

        initialize: function initialize (options) {
            this.structure = options.structure;
            this.model = new StructureProfile.Models.ParticipationRequest(options.model || {});
            Backbone.Validation.bind(this);
            _.bindAll(this, 'showPopupMessageDidntSend');
        },

        showPhoneNumbers: function showPhoneNumbers () {
            this.$('.phone_number').slideToggle();
        },

        toggleRequestType: function toggleRequestType (event) {
            this.ui.$request_type_labels.removeClass('f-weight-bold');
            this.ui.$request_type_labels.find('i').addClass('visibility-hidden');
            this.ui.$request_type_labels.filter('[data-type="' + this.ui.$request_type_inputs.filter(':checked').val() + '"]').find('i').removeClass('visibility-hidden');
            this.$('[data-type="' + this.ui.$request_type_inputs.filter(':checked').val() + '"]').addClass('f-weight-bold');
            this.ui.$request_type_inputs.find(':selected').val()
            if (this.ui.$request_type_inputs.filter(':checked').val() == 'booking') {
                this.ui.$information_request_type_wrapper.hide();
                this.ui.$booking_request_type_wrapper.show();
            } else {
                this.ui.$information_request_type_wrapper.show();
                this.ui.$booking_request_type_wrapper.hide();
            }
        },

        initializeStartHourSelect: function initializeStartHourSelect () {
            _.each(['06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23'], function(value) {
                this.ui.$start_hour_select_input.append($('<option>').attr('value', parseInt(value)).text(value));
            }.bind(this));
        },
        /*
         * Set attributes on message model for validations
         */
        populateRequest: function populateRequest (event) {
            this.model.set({
                request_type  : this.ui.$request_type_inputs.filter(':checked').val(),
                structure_id  : this.structure.get('id'),
                date          : this.$('[name=date]').val(),
                start_hour    : this.$('[name=start-hour]').val(),
                start_min     : this.$('[name=start-min]').val(),
                message: {
                    body: this.$('[name="message[body]"]').val()
                },
                user: {
                    phone_number: this.$('[name="user[phone_number]"]').val()
                }
            });
        },

        /*
         * Called when a user click on "register" on a planning
         * We create an instance of a message form view
         */
        showRegistrationForm: function showRegistrationForm (planning_data) {
            if (this.structure.get('courses').findWhere({ id: planning_data.course_id })) {
                this.model.set('course_collection_type', 'courses');
            } else {
                this.model.set('course_collection_type', 'trainings');
            }
            this.model.set('course_id', planning_data.course_id);
            this.model.set('planning_id', planning_data.id);
            this.selectCourse();
            this.populatePlannings();
            var message_form_view = new Module.RequestFormView( { structure: this.structure, model: this.model.toJSON().participation_request } ).render();
            $.magnificPopup.open({
                  items: {
                      src: $(message_form_view.$el),
                      type: 'inline'
                  }
            });
            message_form_view.$el.css('max-width', '400px');
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
            this.selected_course_collection_type = this.ui.$course_select.find('option:selected').data('collection-type');
            this.model.set('course_collection_type', this.ui.$course_select.find('option:selected').data('collection-type'));
            this.selected_course                 = this.structure.get(this.selected_course_collection_type).findWhere({ id: course_id });
            this.model.set('course_id', course_id);
            this.selectCourse();
        },

        /*
         * Return course model
         */
        getCurrentCourse: function getCurrentCourse () {
            return this.structure.get(this.model.get('course_collection_type')).findWhere({ id: this.model.get('course_id') });
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
            if (this.model.get('course_collection_type') == 'courses') {
                this.ui.$datepicker_wrapper.slideDown();
            } else {
                this.ui.$datepicker_wrapper.slideUp();
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

        trackEvent: function trackEvent () {
            if (CoursAvenue.isProduction()) {
              mixpanel.track('Structures/show: interacts with the form');
            }
        },
        /*
         * Called when the form is submitted.
         * If user is connected, will post the message, else, will ask to login first.
         */
        submitForm: function submitForm () {
            if (CoursAvenue.isProduction()) { mixpanel.track('Structures/show: submit form'); }
            this.populateRequest();
            if (this.model.isValid(true)) {
                if (CoursAvenue.currentUser().isLogged()) {
                    this.$('form').trigger('ajax:beforeSend.rails');
                    this.saveMessage();
                } else {
                    CoursAvenue.signUp({
                        title: 'Enregistrez-vous pour envoyer votre message',
                        // Passing the user in order to keep the email and more if we need.
                        user: this.model.get('user'),
                        success: function success (response) {
                            this.saveMessage();
                        }.bind(this),
                        dismiss: this.showPopupMessageDidntSend
                    });
                }
            } else {
                this.errors = this.model.validate();
                if (this.errors['user.phone_number']) {
                    this.errors.user = { phone_number: this.errors['user.phone_number'] }
                }
                this.render();
            }
            return false;
        },

        /*
         * Save message model. Will make a POST request to save the message.
         */
        saveMessage: function saveMessage () {
            this.$('.input_field_error').remove();
            this.model.save(null, {
                success: function success (model, response) {
                    // We disable the submit button
                    this.$('form').trigger('ajax:complete.rails');
                    $.magnificPopup.open({
                          items: {
                              src: $(response.popup_to_show),
                              type: 'inline'
                          }
                    });
                    if (CoursAvenue.isProduction()) { mixpanel.track("Dismissed request form view"); }
                }.bind(this),
                error: this.showPopupMessageDidntSend
            });
        },

        showPopupMessageDidntSend: function showPopupMessageDidntSend (model, response) {
              this.$('form').trigger('ajax:complete.rails');
              var popup_to_show = JSON.parse(response.responseText).popup_to_show;
              $.magnificPopup.open({
                    items: {
                        src: $(popup_to_show),
                        type: 'inline'
                    }
              });
        },

        serializeData: function serializeData () {
            var data = this.model.toJSON();
            if (this.errors) { _.extend(data, { errors: this.errors }); }
            var structure_json       = this.structure.toJSON();
            structure_json.courses   = this.structure.get('courses').toJSON();
            structure_json.trainings = this.structure.get('trainings').toJSON();
            if (CoursAvenue.currentUser().get('last_messages_sent')) {
                _.extend(data, {
                    last_message_sent_at: CoursAvenue.currentUser().get('last_messages_sent')[structure_json.id]
                });
            }
            _.extend(data, {
                structure: structure_json,
            });
            return data;
        }
    });

}, undefined);

