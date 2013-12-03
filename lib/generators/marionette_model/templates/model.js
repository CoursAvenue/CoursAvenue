
/* just a basic backbone model */
<%= app %>.module('Models<%= (namespace ? "." + namespace : "") %>', function(Module, App, Backbone, Marionette, $, _) {
    Module.<%= name %> = Backbone.<%= backbone_class %>.extend({
        // your implementation here

    });
});

