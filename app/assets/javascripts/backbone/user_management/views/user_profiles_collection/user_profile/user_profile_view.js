UserManagement.module('Views.UserProfilesCollection.UserProfile', function(Module, App, Backbone, Marionette, $, _) {

    var ENTER  = 13;
    var ESC    = 27;

    Module.UserProfileView = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'user_profile_view',
        tagName: 'tr',
        className: 'table__cell--editable unflipped',

        initialize: function (options) {
            this.finishEditing = _.bind(this.finishEditing, this);

            this.model.set("checked", options.checked);
            this.edits = {};

            /* TODO we would like not to have to use the on syntax
             * it would be nice to be able to just include these events
             * in the hash below... */
            this.on("field:click",    this.startEditing);
            this.on("field:key:down", this.finishEditing);
            this.on("field:edits",    this.collectEdits);
        },

        /* incrementally build up a set of attributes */
        collectEdits: function (edits) {
            this.edits[edits.attribute] = edits.data;
        },

        onRender: function () {
            this.ui.$editable.each(_.bind(function (index, element) {
                var attribute = $(element).data("name"),
                    data = this.model.get(attribute);

                var view = new Module.EditableText.EditableTextView({
                    data: data,
                    attribute: attribute
                });

                this.showWidget(view, {
                    events: {
                        'start:editing'     : 'startEditing',
                        'update:success'    : 'commit',
                        'rollback'          : 'rollback',
                        'update:error'      : 'rollback'
                    },
                    selector: '[data-type=editable-' + attribute + ']'
                });
            }, this));
        },

        ui: {
            '$editable': "[data-behavior=editable]",
            '$editing' : "[data-behavior=editable]:has('input')",
            '$checkbox': "[data-behavior=select]"
        },

        events: {
            'focusout'            : 'handleBlur',
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

        /* called: when an editable is clicked */
        /* notifies all the other editables in the layout
        *  and gets them started
        *  gives focus to the editable that was clicked */
        startEditing: function (editable) {
            /* clicking an already active editable does nothing */
            if (editable.isEditing()) {
                return;
            }

            /* tell all the other fields to start themselves */
            this.trigger("start:editing");

            /* give the main dude focus */
            /* TODO I presume this will fail due to asynchronicity later */
            editable.$el.find("input").focus();

            this.trigger("toggle:editing");
        },

        /* given a $field, replace that $field's contents with text */
        finishEditing: function (e) {
            var $fields   = this.$(this.ui.$editing.selector);
            var update    = {
                user_profile: this.edits
            };

            if (e.restore) {
                this.trigger("rollback");

            } else {
                this.model.save(update, {
                    error: _.bind(function (model, response) {
                        /* display a flash containing the error message */
                        GLOBAL.flash(response.responseJSON.errors.join("\n"), "alert");
                        this.startEditing({ target: { tagName: "DIV" }});
                    }, this),
                    wait: true

                /* apply changes to the DOM based on whether out commit was rejected */
                }).success(_.bind(function (response) {
                    this.trigger("update:success", response);
                }, this)).error(_.bind(function () {
                    this.trigger("update:error");
                }, this));
            }

            /* if the user clicked a button to get here, then hide buttons */
            if (e.source === "button") {
                this.trigger("toggle:editing", { blur: true });
            }

            this.edits = {};
        }
    });
});
