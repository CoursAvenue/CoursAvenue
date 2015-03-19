Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListsCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'mailing_lists_collection_view',
        tagName: 'div',
        childViewContainer: '[data-type=mailing-list]',
        childView: Module.MailingListView,
        childViewEventPrefix: 'mailing_list',

        initialize: function initialize () {
        },

        getEmptyView: function getEmptyView () {
          return Module.MailingListsEmptyCollectionView;
        },

        templateHelpers: function templateHelpers () {
            return {
                showAllProfilesOption: function () {
                    return this.collection.hasAllProfilesList();
                }.bind(this),

                hasElements: function () {
                    return !this.collection.isEmpty();
                }.bind(this),
            };
        },
    });
});
