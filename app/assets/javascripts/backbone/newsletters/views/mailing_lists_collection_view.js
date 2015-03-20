Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListsCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'mailing_lists_collection_view',
        tagName: 'div',
        childViewContainer: '[data-type=mailing-list]',
        childView: Module.MailingListView,
        childViewEventPrefix: 'mailing_list',

        events: {
            'click button[type=submit]': 'saveModel',
            'click [data-import]':       'importList',
        },

        initialize: function initialize (options) {
            this.model = options.model;
            _.bindAll(this, 'saveModel', 'importList');
        },

        saveModel: function saveModel () {
            selected = this.collection.findWhere({ selected: true })
            if (!selected) {
                COURSAVENUE.helperMethods.flash('Veuillez choisir une liste de diffusion', 'alert')
            } else {
                this.trigger('selected', { model: selected });
            }
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

        importList: function importList () {
            debugger
            this.model.save();
            var path = Routes.new_pro_structure_user_profile_import_path( window.coursavenue.bootstrap.structure, {
                    newsletter_id: this.model.get('id')
                });

                window.location = path;
        },
    });
});
