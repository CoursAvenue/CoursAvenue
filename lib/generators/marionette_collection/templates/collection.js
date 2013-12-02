
/* just a basic backbone model */
<%= app %>.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.<%= collection_name(name) %> = Backbone.<%= backbone_class %>.extend({
        // your implementation here

    });
});

