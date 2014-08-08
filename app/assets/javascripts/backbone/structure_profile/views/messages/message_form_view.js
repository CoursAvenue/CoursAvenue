StructureProfile.module('Views.Messages', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.MessageFormView = Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'message_form_view',

        initialize: function initialize (options) {
            this.structure = options.structure;
            this.model = new StructureProfile.Models.Message();
        },

        events: {
            'submit form': 'submitForm'
        },

        populateMessage: function populateMessage (event) {
            this.model.set({
                structure_id  : this.structure.get('id'),
                extra_info_ids: _.map(this.$('[name="extra_info_ids[]"]:checked'), function(input) { return input.value }),
                course_ids    : _.map(this.$('[name="course_ids[]"]:checked'), function(input) { return input.value }),
                body          : this.$('[name=body]').val(),
                user: {
                    first_name  : this.$('[name="user[first_name]"]').val(),
                    email       : this.$('[name="user[email]"]').val(),
                    phone_number: this.$('[name="user[phone_number]"]').val()
                }
            });
        },

        submitForm: function submitForm () {
            this.populateMessage();
            var user = {
                first_name  : this.$('[name="user[first_name]"]').val(),
                email       : this.$('[name="user[email]"]').val(),
                phone_number: this.$('[name="user[phone_number]"]').val()
            };
            // this.model.validate();
            CoursAvenue.login({
                user: user,
                success: function success () {
                    this.submitMessage();
                }.bind(this),
                dismiss: function dismiss () {
                    alert(':(');
                }.bind(this)
            })
            return false;
        },

        submitMessage: function() {
            this.model.sync({
                success: function success (response) {
                    $.magnificPopup.open({
                          items: {
                              src: $(response.popup_to_show),
                              type: 'inline'
                          }
                    });
                },
                error: function error () {
                    debugger
                }
            });
        },

        onAfterShow: function onAfterShow () {
            GLOBAL.chosen_initializer();
        },

        serializeData: function serializeData () {
            return {
                structure: this.structure.toJSON(),
                prefilled_body: "Bonjour,\n\nJe souhaiterais venir pour une première séance. Pouvez-vous m’envoyer la date du prochain cours et toutes les autres informations nécessaires (tenue exigée, confirmation du lieu, etc.).\n\nMerci et à très bientôt"
            }
        }
    });

}, undefined);
