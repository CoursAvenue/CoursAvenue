
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PriceView = Marionette.ItemView.extend({
        template: Module.templateDirname() + 'price_view',
        tagName: 'tr'
    });

}, undefined);
