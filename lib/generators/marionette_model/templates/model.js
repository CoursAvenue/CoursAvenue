
/* just a basic backbone model */
<%= app %>.module('Models<%= (!namespace.blank? ? "." + namespace : "") %>', function(Module, App, Backbone, Marionette, $, _) {
    Module.<%= name %> = Backbone.<%= backbone_class %>.extend({
        // your implementation here

    });
});

