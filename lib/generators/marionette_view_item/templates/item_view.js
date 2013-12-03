
/* just a basic marionette view */
<%= app %>.module('Views<%= (namespace ? "." + namespace : "") %>', function(Module, App, Backbone, Marionette, $, _) {

    Module.<%= "#{name}View" %> = Backbone.Marionette.<%= backbone_class %>.extend({
        template: Module.templateDirname() + '<%= name.underscore %>_view',
        tagName: 'div',
        className: '<%= name.underscore %>',
        attributes: {
            'data-behaviour': '<%= name.underscore %>'
        }
    });
});
