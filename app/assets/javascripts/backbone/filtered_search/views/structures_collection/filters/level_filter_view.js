
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.LevelFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'level_filter_view',

        setup: function (data) {
            this.activateButton(data.level_value);
        },

        events: {
            'change [type="radio"]': 'announceSubject'
        },

        announceSubject: function (e, data) {
            var level_value = e.currentTarget.getAttribute('value');
            this.trigger("filter:level", { 'level_value': level_value });
            this.activateButton(level_value);
        },

        disabledButton: function(level_value) {
            this.$('[value=' + level_value + ']').removeClass('active');
        },

        activateButton: function(level_value) {
            this.$('[type="radio"]').prop('checked', false);
            this.$('[value=' + level_value + ']').prop('checked', true);
        }
    });
});
