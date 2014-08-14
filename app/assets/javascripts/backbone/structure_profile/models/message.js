/* just a basic backbone model */
StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.Message = Backbone.Model.extend({

        initialize: function initialize () {
            if ($.cookie('last_sent_message')) {
                this.set(JSON.parse($.cookie('last_sent_message')));
            }
            if (CoursAvenue.currentUser()) {
                this.set('user', CoursAvenue.currentUser().toJSON());
            }
        },

        // Validates the form
        // Might want to use https://github.com/powmedia/backbone-forms at some point
        // Return Boolean, wether it's valid or not
        valid: function validate () {
            errors = {};
            if (!this.get('body') || this.get('body').length == 0) {
                errors['body'] = 'Doit être rempli'
            }
            this.set('errors', errors);
            return _.isEmpty(errors);
        },

        url: function url () {
            return Routes.structure_messages_path({ structure_id: this.get('structure_id') });
        },

        sync: function sync (options) {
            $.ajax({
                beforeSend: function beforeSend (xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
                },
                url: this.url(),
                type: 'POST',
                dataType: 'json',
                data: {
                    message: this.toJSON()
                },
                error: function error (response) {
                    if (options.error) { options.error(response); }
                },
                success: function success (response) {
                    if (options.success) { options.success(response); }
                }
            });
        }
    });
});
