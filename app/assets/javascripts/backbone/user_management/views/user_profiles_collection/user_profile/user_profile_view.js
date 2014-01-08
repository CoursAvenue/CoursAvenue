UserManagement.module('Views.UserProfilesCollection.UserProfile', function(Module, App, Backbone, Marionette, $, _) {

    var ENTER  = 13;
    var ESC    = 27;

    Module.UserProfileView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'user_profile_view',
        tagName: 'tr',
        className: 'table__cell--editable unflipped',

        initialize: function (options) {
            this.finishEditing = _.bind(this.finishEditing, this);

            this.model.set("checked", options.checked);
        },

        ui: {
            '$editable': "[data-behavior=editable]",
            '$editing' : "[data-behavior=editable]:has('input')",
            '$checkbox': "[data-behavior=select]"
        },

        events: {
            'click @ui.$editable' : 'startEditing',
            'focusout'            : 'handleBlur',
            'keydown'             : 'handleKeyDown',
            'change @ui.$checkbox': 'addToSelected'
        },

        modelEvents: {
            'change': 'updateFields'
        },

        /* TODO when the group action occurs, we need to update the
        *  affected fields that are visible. The 'tags' are returned
        *  as an object, but we are presenting them as a string.
        *  Maybe the user_profiles model should have just the string? */
        updateFields: function (model) {
            if (this.isEditing()) { return; }

            var changes = model.changed;

            _.each(changes, _.bind(function (change, attribute) {
                var $field = this.$('[data-name=' + attribute + ']');

                if ($field.length > 0 && $field.text() !== change) {
                    $field.text(change);
                }
            }, this));
        },

        isEditing: function () {
            return this.$("input").length > 0;
        },

        addToSelected: function () {
            this.trigger("add:to:selected");
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
            var dom_changes = new $.Deferred();

            /* collect the edits from all the modified fields */
            _.each($fields, _.bind(function (field) {
                var $field    = $(field);
                var $input    = $field.find("input");
                var attribute = $field.data("name");

                /* TODO for now all fields are text, but later this will get more complicated */
                var old_value = this.model.get(attribute);
                var new_value = $input.val();

                /* collect the potential DOM changes here */
                dom_changes.then(function () {
                    var text = new_value;

                    $field.html(text);
                }, function () {
                    var text = old_value;

                    $field.html(text);
                });

                update.user_profile[attribute] = new_value;
            }, this));

            if (e.restore) {
                dom_changes.reject(); // rrrroll back!

            } else {
                this.model.save(update, {
                    error: _.bind(function (model, response) {
                        /* display a flash containing the error message */
                        GLOBAL.flash(response.responseJSON.errors.join("\n"), "alert");
                        this.startEditing({ target: { tagName: "DIV" }});
                    }, this),
                    wait: true

                /* apply changes to the DOM based on whether out commit was rejected */
                }).success(function () {
                    dom_changes.resolve();
                }).error(function () {
                    dom_changes.reject();
                });
            }

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
