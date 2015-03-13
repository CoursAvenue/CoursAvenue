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

        updateImage: function updateImage () {
            this.model.set('remote_image_url', event.fpfile.url);
            this.$el.find('img').attr('src', event.fpfile.url);
            this.$el.find('img').show();
            this.$el.find('button').hide();
        },

        // TODO:
        // 2. Empty input.
        // 1. Ask for confirmation.
        // 3. Remove image..
        //
        deleteImage: function deleteImage () {
            this.model.set('image', '');

            this.$el.find('img').hide();
            this.$el.find('button').show()
        },

        // Replace the HTML elements with their rich version:
        // - Replacing a `textarea` by a CKeditor,
        // - Replacing a `remote_image_url` input by a filepicker button.
        onRender: function onRender () {
            var textAreas = this.$el.find('[name$=\\[content\\]]');
            var pickers = this.$el.find('[name$=\\[remote_image_url\\]]');

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
