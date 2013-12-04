<%= app %>.module('Views<%= (!namespace.blank? ? "." + namespace : "") %>', function(Module, App, Backbone, Marionette, $, _) {

    Module.<%= layout_name(name) %> = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + '<%= layout_name(name).underscore %>',
        className: '<%= layout_name(name).underscore.gsub(/_/, "-") %>',
        master_region_name: '<%= name.underscore %>',

        regions: {
            master: "#<%= master_region_name %>",
        },

        onShow: function() {
            if (App.$loader) {
                App.$loader().fadeOut('slow');
            }
        },

    });
});

