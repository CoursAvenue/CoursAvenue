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
            'click [data-delete-image]':                   'deleteImage',
            'click [data-edit-image]':                     'editImage',
            'change input[data-type=filepicker-dragdrop]': 'updateImage',
            'change input':                                'silentSave',
        },

        initialize: function initialize () {
            this._modelBinder = new Backbone.ModelBinder();

            var positionLabel = this.model.collection.where({ type: this.model.get('type') }).indexOf(this.model) + 1
            if (this.model.collection.multiBloc) {
                positionLabel = this.model.collection.multiBloc.get('position') + '-' + positionLabel;
            }
            this.model.set('position_label', positionLabel);

            _.bindAll(this, 'onRender', 'editImage', 'deleteImage', 'updateImage', 'onShow', 'silentSave');
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

        updateImage: function updateImage () {
            if (event.fpfile) {
                this.$el.find('.filepicker-dragdrop').hide();

                this.$el.find('img').attr('src', event.fpfile.url);
                this.$el.find('img').show();
                this.$el.find('[data-delete-image-wrapper]').show();
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
        },

        silentSave: function silentSave () {
            this.model.save();
        }.debounce(500),

    })
});
