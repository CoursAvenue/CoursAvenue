Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.NavigationBar = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'navigation_bar',
        tagName: 'div',

        ui: {
            '$preview': '[data-preview]'
        },
        events: {
            'click [data-previous]': 'previousStep',
            'click [data-next]'    : 'nextStep'
        },

        onRender: function onRender () {
            debugger
        },

        nextStep: function nextStep () {
            this.trigger('next');
        },

        previousStep: function previousStep () {
            this.trigger('previous');
        },

        updateButtonsVisibility: function updateButtonsVisibility () {
            debugger
            this.ui.$preview
        }
    });
});
