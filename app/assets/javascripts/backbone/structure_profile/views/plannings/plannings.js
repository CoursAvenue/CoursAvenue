
Daedalus.module('Views.Plannings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.Plannings = Marionette.CompositeView.extend({

        events: {
            'click': 'clicky'
        },

        clicky: function clicky () {
            var data = {
                plannings: this.collection.length
            };

            this.trigger("plannings:announce", data);
        }
    });
});
