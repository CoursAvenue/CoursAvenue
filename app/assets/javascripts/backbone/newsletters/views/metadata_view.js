Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MetadataView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'metadata_view',
        tagName: 'div',

        events: {
            'submit':                'saveModel',
            'click [data-previous]': 'previousStep',
        },

        initialize: function initialize () {
            this._modelBinder = new Backbone.ModelBinder();
            _.bindAll(this, 'saveModel', 'savingError', 'savingSuccess');
        },

        saveModel: function saveModel (event) {
            event.preventDefault();
            this.model.save({}, {
                error:   this.savingError,
                success: this.savingSuccess
            });

            return false;
        },

        savingError: function savingError (model, response, options) {
        },

        savingSuccess: function savingSuccess (model, response, options) {
            this.trigger('edited', { model: this.model });
        },

        // Custom render function.
        // We start by calling the Marionette CompositeView's render function on this view.
        // We then bind the model to the inputs by calling modelBinder.
        render: function render () {
            Backbone.Marionette.ItemView.prototype.render.apply(this, arguments);

            this._modelBinder.bind(this.model, this.$('form'));
        },

        previousStep: function previousStep () {
            this.trigger('previous');
        },
    });
});
