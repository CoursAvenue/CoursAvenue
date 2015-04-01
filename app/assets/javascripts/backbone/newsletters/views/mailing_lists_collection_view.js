Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListsCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'mailing_lists_collection_view',
        tagName: 'div',
        childViewContainer: '[data-type=mailing-list]',
        childView: Module.MailingListView,
        childViewEventPrefix: 'mailing_list',

        events: {
            'click button[type=submit]':  'saveModel',
            'click [data-import]':        'importList',
            'change [data-all-contacts]': 'selectAllContacts',
            'click [data-next]':          'saveModel',
            'click [data-previous]':      'previousStep',
        },

        initialize: function initialize (options) {
            this.model = options.model;
            _.bindAll(this, 'saveModel', 'importList', 'selectAllContacts', 'previousStep');
        },

        getEmptyView: function getEmptyView () {
            return Module.MailingListsEmptyCollectionView;
        },

        templateHelpers: function templateHelpers () {
            var structure = window.coursavenue.bootstrap.structure;

            return {
                showAllProfilesOption: function () {
                    return this.collection.hasAllProfilesList();
                }.bind(this),

                hasElements: function () {
                    return !this.collection.isEmpty();
                }.bind(this),

                previewUrl: Routes.preview_newsletter_pro_structure_newsletter_path(structure, this.model.get('id')),
            };
        },

        saveModel: function saveModel () {
            selected = this.collection.findWhere({ selected: true })
            if (selected || this.all_profiles_selected) {
                this.trigger('selected', { model: selected });
            } else {
                COURSAVENUE.helperMethods.flash('Veuillez choisir une liste de diffusion', 'alert')
            }
        },

        importList: function importList () {
            this.model.save();
            var path = Routes.new_pro_structure_user_profile_import_path( window.coursavenue.bootstrap.structure, {
                newsletter_id: this.model.get('id')
            });

            window.location = path;
        },

        selectAllContacts: function selectAllContacts () {
            var allContacts = new Newsletter.Models.MailingList({ all_profiles: true, newsletter: this.model })
            allContacts.save({}, {
                success: function (model, response, options) {
                    this.model.set('newsletter_mailing_list_id', model.get('id'));
                    this.all_profiles_selected = true
                }.bind(this)
            });
        },

        previousStep: function previousStep () {
            this.trigger('previous');
        },
    });
});
