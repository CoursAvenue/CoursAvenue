Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.MailingListsCollection = Backbone.Collection.extend({
        model: Module.MailingList,

        initialize: function initialize () {
            _.bindAll(this, 'hasAllProfilesList');
        },

        // We use a comparator to show the 'all_profiles' mailing lists first.
        // Otherwiser, we just return their index in their collection.
        comparator: function comparator (model) {
            if (model.has('all_profiles') && model.get('all_profiles') == true) {
                return 0;
            } else {
                return model.collection.indexOf(model);
            }
        },

        hasAllProfilesList: function hasAllProfilesList() {
            return !this.some(function(model) {
                return model.has('all_profiles') && model.get('all_profiles') == true;
            });
        },
    });
});
