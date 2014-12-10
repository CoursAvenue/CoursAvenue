/* just a basic backbone model */
StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.Message = Backbone.Model.extend({

        validation: {
            body: {
                required: true,
                msg: 'Doit être rempli'
            },
            'user.phone_number': {
                maxLength: 20,
                msg: 'Mauvais format'
            }
        },

        initialize: function initialize () {
            if ($.cookie('last_sent_message')) {
                this.set(JSON.parse($.cookie('last_sent_message')));
            }
            if (CoursAvenue.currentUser()) {
                this.set('user', CoursAvenue.currentUser().toJSON());
            }
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
