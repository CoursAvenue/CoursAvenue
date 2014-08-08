/* just a basic backbone model */
StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.Message = Backbone.Model.extend({

        // Validates the form
        validate: function validate () {
            errors = {};
            if (!this.get('body') || this.get('body').length == 0) {
                errors['body'] = true
            }
            // if (!this.get('body') || this.get('body').length == 0) {
            //     errors['body'] = true
            // }
            this.set('errors', errors);
            return errors;
        },

        url: function url () {
            return Routes.structure_messages_path({ structure_id: this.get('structure_id') });
        },

        sync: function sync (options) {
            $.ajax({
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
