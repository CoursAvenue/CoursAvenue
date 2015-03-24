Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.PreviewView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'preview_view',
        tagName: 'div',
        className: 'panel',

        initialize: function initialize () {
            _.bindAll(this, 'onShow');
        },

        templateHelpers: function templateHelpers () {
            var structure = window.coursavenue.bootstrap.structure;
            var newsletter = this.model.get('id');

            return {
                preview_url: function () {
                    return Routes.preview_newsletter_pro_structure_newsletter_path(structure, newsletter);
                },

                send_url: function () {
                    return Routes.send_newsletter_pro_structure_newsletter_path(structure, newsletter);
                },

                confirmation_url: function () {
                    return Routes.confirm_pro_structure_newsletter_path(structure, newsletter);
                },

                save_url: function () {
                    return Routes.pro_structure_newsletters_path(structure);
                },
            };
        },

        // TODO: Find a better way to do this.
        onShow: function onShow () {
            var cookieKey = this.model.id + '_hidePreview';

            if (!$.cookie(cookieKey)) {
                this.$el.find('[data-preview]').click()
                $.cookie(cookieKey, true);
            }
        },
    });
});
