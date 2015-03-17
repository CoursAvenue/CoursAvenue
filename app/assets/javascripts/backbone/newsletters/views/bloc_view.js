Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.BlocView = Backbone.Marionette.ItemView.extend({
        template: function template (model) {
            return JST[Module.templateDirname() + 'bloc_' + model.type](model);
        },
        tagName: 'div',

        events: {
            'click [data-delete-image]'    : 'deleteImage',
            'change input[type=filepicker]': 'updateImage'
        },

        initialize: function initialize () {
            this._modelBinder = new Backbone.ModelBinder();
            _.bindAll(this, 'deleteImage', 'updateImage');
        },

        // Custom render function.
        // We start by calling the Marionette CompositeView's render function on this view.
        // We then bind the model to the inputs by calling modelBinder.
        render: function render () {
            Backbone.Marionette.ItemView.prototype.render.apply(this, arguments);

            this._modelBinder.bind(this.model, this.el);
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
        // - Replacing a `remote_image_url` input by a filepicker button.
        onShow: function onShow () {
            var text_areas = this.$el.find('[data-type=redactor]');
            var pickers    = this.$el.find('[data-type=filepicker-dragdrop]');

            text_areas.each(function(index, elem) {
                $(elem).redactor({
                      buttons: ['formatting', 'bold', 'italic','unorderedlist',
                                'orderedlist', 'link', 'alignment', 'horizontalrule'],
                      lang: 'fr',
                      formatting: ['p', 'blockquote', 'h1', 'h2', 'h3'],
                      blurCallback: function blurCallback (event) {
                          this.$element.trigger('change', event);
                      }
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

    })
});
