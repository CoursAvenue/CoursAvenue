Newsletter.module('Views.Blocs', function(Module, App, Backbone, Marionette, $, _) {
    Module.Image = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'image',
        tagName: 'div',

        className: function className () {
            var classes     = '';
            var layout      = this.model.collection.newsletter.get('layout');
            var disposition = layout.get('disposition');
            var subBlocs    = layout.get('sub_blocs')[this.model.get('position') - 1];
            var proportions = layout.get('proportions')[this.model.get('position') - 1]


            if (this.model.collection.multiBloc && disposition == 'horizontal') {
                var classIndex = subBlocs.indexOf(this.model.get('view_type'));
                classes = 'inline-block soft-half--sides v-top ' + proportions[classIndex];
            } else {
                classes = 'push-half--bottom'
            }

            return classes;
        },

        events: {
            'click [data-behavior=choose-from-gallery]':   'showGallery',
            'click [data-delete-image]':                   'deleteImage',
            'click [data-edit-image]':                     'editImage',
            'change input[data-type=filepicker-dragdrop]': 'updateImage',
            'change input':                                'silentSave',
            'keyup input':                                 'silentSave'
        },

        initialize: function initialize () {
            this._modelBinder = new Backbone.ModelBinder();

            var positionLabel = this.model.collection.where({ type: this.model.get('type') }).indexOf(this.model) + 1
            if (this.model.collection.multiBloc) {
                positionLabel = this.model.collection.multiBloc.get('position');
            }
            this.model.set('position_label', positionLabel);
            if (!this.model.has('newsletter')) {
                this.model.set('newsletter', this.model.collection.newsletter);
            }

            _.bindAll(this, 'onRender', 'editImage', 'deleteImage', 'updateImage', 'onShow', 'silentSave');
        },

        showGallery: function showGallery () {
            var images_collection         = new Backbone.Collection(window.coursavenue.bootstrap.images);
            var image_gallery_picker_view = new Newsletter.Views.ImageGalleryPickerView({ collection: images_collection });
            image_gallery_picker_view.render();
            image_gallery_picker_view.on('image:selected', function(image_model) {
                this.setImage(image_model.get('url'));
                this.model.set('remote_image_url', image_model.get('url'));
                this.silentSave();
                $.fancybox.close();
            }.bind(this));
            $.fancybox.open(image_gallery_picker_view.$el, { width: 800, minWidth: 800, maxWidth: 800, height: 500, minHeight: 500, maxHeight: 500, padding: 0 });
        },

        // Custom render function.
        // We start by calling the Marionette CompositeView's render function on this view.
        // We then bind the model to the inputs by calling modelBinder.
        render: function render () {
            Backbone.Marionette.ItemView.prototype.render.apply(this, arguments);

            this._modelBinder.bind(this.model, this.el);
        },

        onRender: function onRender () {
            if (this.model.has('image')) {
                this.$el.find('img').show();
                this.$el.find('[data-delete-image-wrapper]').show();
            }
        },

        setImage: function setImage (image_url) {
            this.$el.find('.filepicker-wrapper').hide();
            this.$el.find('img').attr('src', image_url);
            this.$el.find('img').show();
            this.$el.find('[data-delete-image-wrapper]').show();
        },

        updateImage: function updateImage () {
            if (event.fpfile) {
                this.setImage(event.fpfile.url);
            } else {
                this.deleteImage();
            }
        },

        editImage: function editImage () {
            this.$el.find('.filepicker-btn').click()
        },

        deleteImage: function deleteImage () {
            this.model.unset('image');
            this.model.set('remote_image_url', '');
            this.model.set('remove_image', '1');
            this.model.save();
            this.model.unset('remove_image');

            this.$el.find('img').hide();
            this.$el.find('img').attr('src', '');
            this.$el.find('[data-delete-image-wrapper]').hide();

            this.render();
            this.onShow();
        },

        // Replace the HTML elements with their rich version:
        // - Replacing a `remote_image_url` input by a filepicker button.
        onShow: function onShow () {
            var pickers    = this.$el.find('[data-type=filepicker-dragdrop]');
            var model      = this.model;

            pickers.each(function(index, elem) {
                // We have to add the type to be able to `constructWidget`
                $(elem).attr('type', $(elem).data('type'));
                filepicker.constructWidget(elem);
                // Remove type to prevent from filepicker JS to initialize it anyway
                $(elem).removeAttr('type');
            });
            if (!this.model.has('id')) {
                // Do not use silent save here.
                // Because if there is two images on the page, only one of them will be saved
                // Prevent from bug, dunnow why...
                setTimeout(function() {
                    this.model.save();
                }.bind(this), 500);
            }
        },

        silentSave: function silentSave () {
            this.model.save();
        }.debounce(500),

        serializeData: function serializeData () {
            return this.model.attributes;
        },
    })
});
