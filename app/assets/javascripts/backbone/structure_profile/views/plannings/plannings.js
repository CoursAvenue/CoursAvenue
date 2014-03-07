
Daedalus.module('Views.Plannings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.Plannings = Marionette.CompositeView.extend({

        events: {
            'fetch:everything': 'fetch'
        },

        fetch: function () {
            $.when(this.collection.fetch()).then(function (){
                this.announce();

            }.bind(this));
        },

        announce: function announce () {
            var data = {
                plannings: this.collection.length
            };

            this.trigger("plannings:announce", data);
        }
    });
});
