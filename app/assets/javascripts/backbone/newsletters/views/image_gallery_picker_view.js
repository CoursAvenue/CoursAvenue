Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.ImageGalleryPickerView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'image_gallery_picker_view',
        childViewContainer: '[data-type=images]',
        childView: Module.ImageView,

        onChildviewSelected: function onChildviewSelected (view, data) {
            this.trigger('image:selected', data);
        }

    });

});
