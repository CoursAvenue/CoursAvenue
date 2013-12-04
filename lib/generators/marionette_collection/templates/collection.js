
/* just a basic backbone model */
<%= app %>.module('Models<%= (!namespace.blank? ? "." + namespace : "") %>', function(Module, App, Backbone, Marionette, $, _) {
    Module.<%= collection_name(name) %> = Backbone.<%= backbone_class %>.extend({
        model: Module.<%= name %>
        // your implementation here

    });
});

