
/* just a basic marionette view */
Emailing.module('Views.EmailingSectionsCollection.EmailingSection.EmailingSection', function(Module, App, Backbone, Marionette, $, _) {

    Module.EmailingSectionView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'emailing_section_view',
        tagName: 'li',
        className: 'emailing-section',
        attributes: {
            'data-behavior': 'emailing-section'
        }
    });
});
