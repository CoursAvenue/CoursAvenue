Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListsCollection = Backbone.Collection.extend({
        model: Module.MailingList,

        // We use a comparator to show the 'all_profiles' mailing lists first.
        // Otherwiser, we just return their index in their collection.
        comparator: function comparator (model) {
            if (model.has('all_profiles') && model.get('all_profiles') == true) {
                return -1;
            } else {
                return model.collection.indexOf(model);
            }
        },

        initialize: function initialize (collection, selected_mailing_list_id) {
            // Set selected attribute to selected mailing list
            _.each(collection, function(mailing_list) {
                if (mailing_list.id == selected_mailing_list_id){
                    mailing_list.selected = true;
                }
            });
        },

        allProfileMailingList: function allProfileMailingList() {
            return this.findWhere({ all_profiles: true });
        },

        updateAllProfileMailingList: function updateAllProfileMailingList(new_recipient_count) {
            this.allProfileMailingList().set({ recipient_count: new_recipient_count});
        }

    });
});
