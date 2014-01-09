
UserManagement.module('Views.UserProfilesCollection.UserProfile.EditableText', function(Module, App, Backbone, Marionette, $, _) {

    var ENTER  = 13;
    var ESC    = 27;

    Module.EditableTextView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'editable_text_view',
        tagName: 'div',
        className: 'editable-text pointer',
        attributes: {
            'data-behavior': 'editable-text'
        },

        initialize: function (options) {
            this.announceEdits = _.debounce(_.bind(this.announceEdits, this), 100);
            this.data = options.data;
            this.attribute = options.attribute;
        },

        events: {
            'click':    'announceClick',
            'keydown':  'handleKeyDown',
            'change':   'announceEdits'
        },

        /* no model here */
        serializeData: function () {

            return {
                data: this.data
            }
        },

        handleKeyDown: function (e) {
            this.announceEdits();

            var key = e.which;
            if (key !== ENTER && key !== ESC) {
                return;
            }

            this.trigger("field:key:down", { editable: this, restore: (key === ESC) });
        },

        getEdits: function () {
            var edits = {
                attribute: this.attribute,
                data: this.$el.find("input").val()
            };

            return edits;
        },

        announceEdits: function () {
            this.trigger("field:edits", this.getEdits());
        },

        announceClick: function () {
            this.trigger("field:click", this); // TODO we are passing out the whole view for now
        },

        startEditing: function () {
            this.is_editing = true;
            var text = this.$el.text();
            var $input = $("<input>").prop("value", text);

            this.$el.html($input);
        },

        stopEditing: function () {
            this.is_editing = false;
            this.$el.html(this.data);
        },

        commit: function (data) {
            this.data = data[this.attribute];

            this.stopEditing();
        },

        rollback: function () {
            this.stopEditing();
        },

        isEditing: function () {
            return this.is_editing === true;
        },

    });
});
