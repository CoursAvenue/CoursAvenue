
/* just a basic marionette view */
CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    /* TODO these should be defined in just one place */
    var ENTER     = 13;
    var ESC       = 27;

    Module.EditableFieldView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'editable_field_view',
        tagName: 'li',
        className: 'editable-field',
        attributes: {
            'data-behavior': 'editable-field'
        },

        constructor: function (options) {
            Marionette.ItemView.prototype.constructor.apply(this, arguments);

            this.data          = options.data;
            this.attribute     = options.attribute;
        },

        $input: function () {
            return this.$el.find("input").focus();
        },

        /* return a handler function for the given key if one exists */
        getHandler: function (key) {
            var handler = this[key];

            if (handler === undefined) {
                return handler;
            }

            return _.bind(this[key], this);
        },

        /* editables might override this method */
        getFieldContents: function () {
            return this.$("input").val();
        },

        announceEdits: function () {
            var edits = this.getEdits();
            this.trigger("field:edits", edits);
        },

        /* we do "focus" twice here: before we start editing
        * it will be ignore, so we do it again after start.
        * Once we are editing, if we click the field again
        * we want to ensure the input gets focus. In that case
        * the function will bail right after the first focus,
        * so in both cases we don't get duplication. */
        announceClick: function (e) {
            this.trigger("field:click", e);
            this.$input().focus();
            /* we don't care if you click on an input */
            if (this.isEditing()) { return; }

            this.startEditing(); // this field should start right away
            this.$input().focus();
            this.trigger("text:click");
        },

        /* construct and show the taggy */
        startEditing: function () {
            if (this.isEditing()) { return; }

            this.setEditing(true);
            this.activate();
        },

        /* purely visual: whatever was in the input, change it to text */
        stopEditing: function () {
            this.setEditing(false);
            this.deactivate();
        },

        /* update the data, nothing visual */
        commit: function (data) {
            this.data = data[this.attribute];
        },

        /* forcibly update the data */
        /* a commit is made by updating the rollback point, and
        * then rolling back. Essentially we are rolling forward.
        * Like ninjas... */
        setData: function (data) {
            if (data[this.attribute] !== undefined) {
                this.commit(data);
                this.rollback();
            }
        },

        activate: function () {
            throw new ReferenceError("Virtual method `activate` called on " + this.cid);
        },

        deactivate: function () {
            throw new ReferenceError("Virtual method `deactivate` called on " + this.cid);
        },

        handleKeyDown: function (e) {
            var key     = e.which;
            var text    = this.getFieldContents();
            var handler = this.getHandler(key);

            if (handler) {
                handler(text, e); // call the appropriate handler method
            }

            if (key === ENTER || key === ESC) {
                this.trigger("field:key:down", { editable: this, restore: (key === ESC) });
            }
        },

        /* no model here so we have to return data */
        serializeData: function () {

            return {
                data: this.data
            };
        },

        isEditing: function () {
            return this.is_editing === true;
        },

        setEditing: function (value) {
            this.is_editing = value;
            this.trigger("set:editing", value);
        },

    });
});
