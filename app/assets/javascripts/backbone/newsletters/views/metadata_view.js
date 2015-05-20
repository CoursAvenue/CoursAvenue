Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MetadataView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'metadata_view',
        tagName: 'div',

        events: {
            'change input': 'silentSave',
            'keyup input' : 'silentSave'
        },

        initialize: function initialize () {
            this._modelBinder = new Backbone.ModelBinder();
            this.model.set('email_object', this.model.get('email_object') || this.model.get('title'))
            _.bindAll(this, 'silentSave');
        },

        silentSave: function silentSave (event) {
            if (event) { event.preventDefault(); }
            this.model.save();

            return false;
        }.debounce(500),

        onShow: function onShow () {
            this.silentSave();
        },

        // Custom render function.
        // We start by calling the Marionette CompositeView's render function on this view.
        // We then bind the model to the inputs by calling modelBinder.
        render: function render () {
            Backbone.Marionette.ItemView.prototype.render.apply(this, arguments);

            this._modelBinder.bind(this.model,
                                   this.$('form'),
                                   null,
                                   { changeTriggers:
                                      { '': 'keyup change', '[contenteditable]': 'blur' } });
        },

        previousStep: function previousStep () {
            this.trigger('previous');
        },
    });
});
