Emailing.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.EmailingSectionsLayout = CoursAvenue.Views.EventLayout.extend({
        template: Module.templateDirname() + 'emailing_sections_layout',
        className: 'emailing-sections-layout',
        master_region_name: 'emailing_section',

        regions: {
            master: "#emailing-sections",
        }
    });
});
