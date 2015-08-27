Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListsCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'mailing_lists_collection_view',
        tagName: 'div',
        childViewContainer: '[data-type=mailing-list]',
        childView: Module.MailingListView,

        initialize: function initialize (options) {
            this.model = options.model;
        },

        onRender: function onRender () {
            var mailing_list_import_view = new Module.MailingListImportView({ model: this.model, collection: this.collection });
            this.$('[data-type=import-view]').append(mailing_list_import_view.render().$el);
            mailing_list_import_view.on('selected', function(data) {
                this.trigger('selected', data);
            }.bind(this))
        },

        onChildviewSelected: function onChildviewSelected (mailing_list_view) {
            this.trigger('selected', { model: mailing_list_view.model });
        },

        childViewOptions: function childViewOptions (model, index) {
            return {
                model: model,
                newsletter: this.model
            }
        }
    });
});
