Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.BlocsCollection = Backbone.Collection.extend({
        model: Module.Bloc,
        comparator: 'position',

        initialize: function initialize (models, options) {
            this.newsletter = options.newsletter;

            _.bindAll(this, 'setNewsletter');

            _.defer(this.setNewsletter);
        },

        setNewsletter: function setNewsletter () {
            _.each(this.models, function(model) {
                model.set('newsletter', this.newsletter)
            }, this)
        },
    });
});
