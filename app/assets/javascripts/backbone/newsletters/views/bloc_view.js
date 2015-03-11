Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.BlocView = Backbone.Marionette.ItemView.extend({
        template: function template (model) {
            return JST[Module.templateDirname() + 'bloc_' + model.type](model);
        },
        tagName: 'div',

        events: {
            'click [data-delete-image]': 'deleteImage',
            'change input[type=filepicker]': 'updateImage'
        },

        initialize: function initialize () {
            _.bindAll(this, 'deleteImage', 'updateImage');
        },

        updateImage: function updateImage (event) {
            // this.$el.find('img[data-fpimage]#').attr('src', event.originalEvent.fpfile.url);
        },

        // TODO:
        // 2. Empty input.
        // 1. Ask for confirmation.
        // 3. Remove image..
        //
        deleteImage: function echo (event) {
            console.log(event);
        },

    })
});
