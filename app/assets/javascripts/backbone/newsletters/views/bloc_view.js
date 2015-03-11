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

        initialize: function initialize (options) {
            _.bindAll(this, 'deleteImage', 'updateImage');
        },

        updateImage: function updateImage (event) {
        },

        // TODO:
        // 2. Empty input.
        // 1. Ask for confirmation.
        // 3. Remove image..
        //
        deleteImage: function echo (event) {
            console.log(event);
        },

        // Replace the HTML elements with their rich version:
        // - Replacing a `textarea` by a CKeditor,
        // - Replacing a `remote_image_url` input by a filepicker button.
        onRender: function onRender () {
            var textAreas = this.$el.find('[name$=\\[content\\]]');
            var pickers = this.$el.find('[name$=\\[remote_image_url\\]]');

            // CKEDITOR.replaceAll();
            textAreas.each(function(index, elem) {
                CKEDITOR.replace(elem);
            });

            if (!this.model.collection.initialRender) {
                pickers.each(function(index, elem) {
                    filepicker.constructWidget(elem);
                });
            }

            if (this.model.collection.initialRender) {
                this.model.collection.initialRender = false;
            }
        },

    })
});
