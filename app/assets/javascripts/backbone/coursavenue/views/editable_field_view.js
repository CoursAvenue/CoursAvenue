
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

        /* return a handler function for the given key if one exists */
        getHandler: function (key) {
            var handler = this[key];

            if (handler === undefined) {
                return handler;
            }

            return _.bind(this[key], this);
        },

        getFieldContents: function () {
            return this.$("input").val();
        },

        handleKeyDown: function (e) {
            var key = e.which;
            var text = this.getFieldContents();
            var handler = this.getHandler(key);

            if (handler) {
                handler(text, e); // call the appropriate handler method
            }

            if (key === ENTER || key === ESC) {
                this.trigger("field:key:down", { editable: this, restore: (key === ESC) });
            }
        }
    });
});
