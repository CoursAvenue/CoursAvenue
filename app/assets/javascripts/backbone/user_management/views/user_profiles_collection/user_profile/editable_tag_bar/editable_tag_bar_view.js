
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.UserProfile.EditableTagBar', function(Module, App, Backbone, Marionette, $, _) {

    var ENTER  = 13;
    var ESC    = 27;

    Module.EditableTagBarView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'editable_tag_bar_view',
        tagName: 'div',
        className: 'editable-tag-bar pointer',
        attributes: {
            'data-behavior': 'editable-tag-bar'
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
                attribute: "tags",
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
            this.trigger("field:click", this.$el.find("input")); // TODO we are passing out the whole view for now
        },

        startEditing: function () {
            if (this.isEditing()) { return; }

            this.is_editing = true;
            var text = this.$el.text();
            var $input = $("<input>").prop("value", text);

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
