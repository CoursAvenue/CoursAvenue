/* TODO consider making every field on the itemview editable on click, rather than one
*  field at a time. This shows "we are editing this model", and lets us put the "commit"
*  button in a consistent place. */

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
            'click @ui.$editable' : 'startEditing',
            'focusout'            : 'handleBlur',
            'keydown'             : 'handleKeyDown'
        },

        /* the row has lost focus */
        handleBlur: function (e) {
            var self = this;
            var $field = $(e.target);
            /* a hack to determine whether it was the row, or a field
            *  that triggered the blur event
            *  see: http://stackoverflow.com/questions/121499/when-onblur-occurs-how-can-i-find-out-which-element-focus-went-to */
            setTimeout(_.bind(function() {
                var $target = $(document.activeElement);

                /* if focus is moving within the row, NOP */
                /* if focus is moving outside the table, return focus to the input */
                if (this.$el.find($target).length > 0) {
                    return;
                } else if ($target[0].tagName === "BODY") {

                    $field.focus();
                    return;
                }



                this.finishEditing(e);

            }, this), 1);
        },

        startEditing: function (e) {
            /* clicking inside the input does nothing */
            if (e.target.tagName === "INPUT") {
                return;
            }

            var $fields    = this.ui.$editable;

            _.each($fields, function (field) {
                var $field = $(field);
                var text = $field.text();
                var $input = $("<input>").prop("value", text);

                $field.html($input);
            });

            var $current     = $(e.currentTarget).find("input");
            $current.focus();
            this.trigger("toggle:editing");
        },

        /* given a $field, replace that $field's contents with text */
        finishEditing: function (e) {
            var $fields   = this.$(this.ui.$editing.selector);
            var update    = {
                user_profile: { }
            };

            _.each($fields, _.bind(function (field) {
                var $field    = $(field);
                var $input    = $field.find("input");
                var attribute = $field.data("name");
                var text      = (e.restore)? this.model.get(attribute) : $input.val();

                $field.html(text);
                update.user_profile[attribute] = text;
            }, this));

            this.model.save(update, {
                success: function (model, response) {
                    console.log(model);
                    console.log(response);
                },
                error: function (model, response) {
                    GLOBAL.flash(response.responseJSON.errors.join("\n"), "error");
                    console.log(model);
                    console.log(response);
                    /* display a flash containing the error message */
                    /* persist the user's changes */
                },
                wait: true
            });

            /* if the user clicked a button to get here, then hide buttons */
            if (e.source === "button") {
                this.trigger("toggle:editing", { blur: true });
            }
        },

        handleKeyDown: function (e) {
            var key = e.which;
            if (key !== ENTER && key !== ESC) {
                return;
            }

            this.trigger("toggle:editing", { blur: true });
            this.finishEditing({ currentTarget: e.target, restore: (key === ESC) });
        },
    });
});
