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

        templateHelpers: function templateHelpers () {
            var structure = window.coursavenue.bootstrap.structure;

            return {
                showAllProfilesOption: function showAllProfilesOption () {
                    return this.collection.hasAllProfilesList();
                }.bind(this),

                hasElements: function hasElements () {
                    return !this.collection.isEmpty();
                }.bind(this)
            };
        },

        onRender: function onRender () {
            var mailing_list_import_view = new Module.MailingListImportView({ model: this.model, collection: this.collection });
            this.$('[data-type=import-view]').append(mailing_list_import_view.render().$el);
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
                    this.collection.add(model);

                    this.model.set('newsletter_mailing_list_id', model.get('id'));
                    this.model.save();

                    this.all_profiles_selected = true

                    this.render();
                    this.trigger('selected', { model: model });
                }.bind(this)
            });
        },

        previousStep: function previousStep () {
            this.trigger('previous');
        },
    });
});
