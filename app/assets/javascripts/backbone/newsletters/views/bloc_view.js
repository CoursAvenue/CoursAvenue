Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.BlocView = Backbone.Marionette.ItemView.extend({
        template: function template (model) {
            return JST[Module.templateDirname() + 'bloc_' + model.view_type](model);
        },
        tagName: 'div',

        events: {
            'click [data-delete-image]':                   'deleteImage',
            'click [data-edit-image]':                     'editImage',
            'change input[data-type=filepicker-dragdrop]': 'updateImage',
            'change input':                                'silentSave',
            'change textarea':                             'silentSave'
        },

        initialize: function initialize () {
            this._modelBinder = new Backbone.ModelBinder();

            var position_label = this.model.collection.where({type: this.model.get('type')}).indexOf(this.model) + 1
            this.model.set('position_label', position_label);

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

        // TODO:
        // 2. Empty input.
        // 1. Ask for confirmation.
        // 3. Remove image..
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
            var text_areas = this.$el.find('[data-type=redactor]');
            var pickers    = this.$el.find('[data-type=filepicker-dragdrop]');
            var model      = this.model;

            text_areas.each(function(index, elem) {
                $(elem).redactor({
                      buttons: ['formatting', 'bold', 'italic','unorderedlist',
                                'orderedlist', 'link', 'alignment', 'horizontalrule'],
                      lang: 'fr',
                      formatting: ['p', 'blockquote', 'h1', 'h2', 'h3'],
                      blurCallback: function blurCallback (event) {
                          this.$element.trigger('change', event);
                      },
                      initCallback: function initCallback () {
                          if (model.has('content')) {
                              this.code.set(model.get('content'));
                          }
                      },
                });
            });

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
