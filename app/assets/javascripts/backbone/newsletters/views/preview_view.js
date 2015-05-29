Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.PreviewView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'preview_view',
        tagName: 'div',

        initialize: function initialize () {
            _.bindAll(this, 'onShow');
        },

        templateHelpers: function templateHelpers () {
            var structure  = window.coursavenue.bootstrap.structure;
            return {
                confirmation_url: function confirmation_url () {
                    return Routes.confirm_pro_structure_newsletter_path(structure, this.model.get('id'));
                }.bind(this),
                save_url: function save_url () {
                    return Routes.pro_structure_newsletters_path(structure);
                }.bind(this),
                email_object: function email_object () {
                    return this.model.get('email_object');
                }.bind(this),
                sender_name: function sender_name () {
                    return this.model.get('sender_name');
                }.bind(this)
            };
        },

        onShow: function onShow () {
            var structure  = window.coursavenue.bootstrap.structure;
            var newsletter = this.model.get('id');
            var preview_url = Routes.preview_newsletter_pro_structure_newsletter_path(structure, newsletter);

            $.ajax(preview_url, {
                success: function success (data, status, reqest) {
                    var frame = this.$el.find('[data-preview]')

                    frame.contents().find('html').html(data);
                    frame.contents().find('img').css('max-width', '100%')
                }.bind(this),
            });
        },
    });
});
