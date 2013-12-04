
/* just a basic backbone model */
<%= app %>.module('Models<%= (!namespace.blank? ? "." + namespace : "") %>', function(Module, App, Backbone, Marionette, $, _) {
    Module.<%= collection_name(name) %> = Backbone.<%= backbone_class %>.extend({
        model: Module.<%= name %>,
        url: function () {
            return 'bob.json'
        },

        /* if fetch returns an object, rather than an array,
        * you will process that object here */
        parse: function (data) {
            return data;
        }

        // your implementation here

    });
});

