
StructureProfile.module('Views.Structure.Places', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PlaceView = Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'place_view',
        tagName: 'li',
        className: 'hoverable',

        events: {
            'mouseenter': 'triggerMouseEnter',
            'mouseleave': 'triggerMouseLeave'
        },

        triggerMouseEnter: function triggerMouseEnter(event) {
            this.trigger("mouseenter", this.model.toJSON());
        },

        triggerMouseLeave: function triggerMouseLeave(event) {
            this.trigger("mouseleave", this.model.toJSON());
        }
    });

}, undefined);
