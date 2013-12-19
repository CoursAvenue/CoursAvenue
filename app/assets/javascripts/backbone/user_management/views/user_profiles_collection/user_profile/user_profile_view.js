
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.UserProfile', function(Module, App, Backbone, Marionette, $, _) {

    var ENTER  = 13;
    var ESC    = 27;

    Module.UserProfileView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'user_profile_view',
        tagName: 'tr',
        className: 'table__cell--editable',

        initialize: function () {
            this.finishEditing = _.bind(this.finishEditing, this);
        },

        ui: {
            '$editable': "[data-behavior=editable]",
            '$editing' : "[data-behavior=editable]:has('input')"
        },

        events: {
            'click @ui.$editable'                  : 'startEditing',
            'blur  [data-behavior=editable] input' : 'finishEditing',
            'keydown'                              : 'handleKeyDown'
        },

        startEditing: function (e) {
            /* clicking inside the input does nothing */
            if (e.target.tagName === "INPUT") {
                return;
            }

            var $field    = $(e.currentTarget);
            var text = $field.text();
            console.log("html: %o", text);
            var $input = $("<input>").prop("value", text);

            $field.html($input);
            $input.focus();
        },

        /* given a $field, replace that $field's contents with text */
        finishEditing: function (e) {
            var $input    = $(e.currentTarget);
            var $field    = $(this.ui.$editing.selector);
            var attribute = $field.data("name");
            var text = $input.val();
            $field.html(text);

            console.log("saving: %o", text);
            if (text !== this.model.get(attribute)) {
                var data = { user_profile: { }};
                data.user_profile[attribute] = text;
                this.model.save(data, {
                    success: function (model, response) {
                        console.log(model);
                        console.log(response);
                    },
                    error: function (model, response) {
                        GLOBAL.flash(response.responseJSON.errors.join("\n"), "error");
                        console.log(model);
                        console.log(response);
                    },
                    wait: true
                });
            }
        },

        handleKeyDown: function (e) {
            var key = e.which;
            if (key !== ENTER && key !== ESC) {
                return;
            }

            var $field    = $(this.ui.$editing.selector);
            var attribute = $field.data("name");
            var $input    = $field.find("input");
            var text      = $input.prop('value') || null;

            // maybe restore the value
            if (key === ESC) {
                text = this.model.get(attribute);
                console.log("model: %o", text);
                $input.val(text);
            }

            this.finishEditing({ currentTarget: e.target });
        },
    });
});
