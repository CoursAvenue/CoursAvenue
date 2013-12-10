
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.AudienceFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'audience_filter_view',
        setup: function (data) {
            this.activateButton(data.audience);
        },

        events: {
            'change [type="radio"]': 'announceSubject'
        },

        announceSubject: function (e, data) {
            var value = e.currentTarget.getAttribute('value');
            this.trigger("filter:audience", { 'audience': value });
            this.activateButton(value);
        },

        disabledButton: function(data) {
            this.$('[value=' + data + ']').removeClass('active');
        },

        activateButton: function(data) {
            this.$('[type="radio"]').prop('checked', false);
            this.$('[value=' + data + ']').prop('checked', true);
        }
    });
});
