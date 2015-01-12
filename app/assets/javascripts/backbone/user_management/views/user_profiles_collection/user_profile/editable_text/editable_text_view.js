
UserManagement.module('Views.UserProfilesCollection.UserProfile.EditableText', function(Module, App, Backbone, Marionette, $, _) {

    var ENTER  = 13;
    var ESC    = 27;

    Module.EditableTextView = CoursAvenue.Views.EditableFieldView.extend({
        template: Module.templateDirname() + 'editable_text_view',
        tagName: 'div',
        className: 'editable-text cursor-pointer',
        attributes: {
            'data-behavior': 'editable-text'
        },

        initialize: function (options) {

            this[ENTER] = this.announceEdits;
        },

        events: {
            'click':    'announceClick',
            'keydown':  'handleKeyDown',
            'change':   'announceEdits'
        },

        getEdits: function () {
            var edits = {
                attribute: this.attribute,
                data: this.$el.find("input").val()
            };

            return edits;
        },

        activate: function () {
            var text   = this.$el.text();
            var $input = $("<input>").prop('type', 'text')
                                     .prop("value", text);

            this.$el.html($input);
        },

        deactivate: function () {
            var data = this.$el.find("input").val();
            this.$el.html(data);
        },

        /* change the text to the old data */
        /* we are choosing not to re-focus the field because
        * this might steal focus from a field in mid edit. */
        rollback: function () {
            this.setEditing(false);
            this.$el.html(this.data);
        },

        // remove trailing whitespace
        sanitize: function sanitize (edit) {
            if (_.isFunction(edit.data.trim)) {
                edit.data = edit.data.trim();
            }

            return edit;
        },

    });
});
