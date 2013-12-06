
StructureProfile.module('Views.Map.GoogleMap', function(Module, App, Backbone, Marionette, $, _) {

    Module.MarkerView = CoursAvenue.Views.Map.GoogleMap.MarkerView.extend({
        events: {
            'click': 'triggerClick'
        },

        triggerClick: function() {
            this.trigger('places:marker:clicked');
        }
    });
});
