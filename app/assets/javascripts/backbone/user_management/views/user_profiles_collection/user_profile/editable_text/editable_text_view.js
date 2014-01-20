
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

            this.data = options.data || "";
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
            /* we don't care if you click on an input */
            if (this.isEditing()) { return; }

            this.startEditing(); // this field should start right away
            this.trigger("text:click", this.$el.find("input")); // TODO we are passing out the whole view for now
        },

        startEditing: function () {
            if (this.isEditing()) { return; }

            this.is_editing = true;
            var text   = this.$el.text();
            var $input = $("<input>").prop('type', 'text').prop("value", text);

            this.$el.html($input);
        },

        /* purely visual: whatever was in the input, change it to text */
        stopEditing: function () {
            this.is_editing = false;
            var data = this.$el.find("input").val();

            this.$el.html(data);
        },

        /* forcibly update the data */
        setData: function (data) {
            this.commit(data);
            this.refresh();
        },

        /* update the data, nothing visual */
        commit: function (data) {
            this.data = data[this.attribute];
        },

        /* change the text to the old data */
        /* we are choosing not to re-focus the field because
        * this might steal focus from a field in mid edit. */
        rollback: function () {
            this.is_editing = false;
            this.$el.html(this.data);
        },

        /* maybe the text has fallen out of sync with the data */
        refresh: function () {
            this.rollback();
        },

        isEditing: function () {
            return this.is_editing === true;
        },

    });
});
