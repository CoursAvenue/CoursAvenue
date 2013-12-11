
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.LevelFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'level_filter_view',

        setup: function (data) {
            var self = this;
            _.each(data.level_ids, function(level_id) {
                self.activateInput(level_id);
            });
        },

        events: {
            'change input': 'announce'
        },

        announce: function (e, data) {
            // var level_value = e.currentTarget.getAttribute('value');
            var level_ids = _.map(this.$('[name="level_ids[]"]:checked'), function(input){ return input.value });
            this.trigger("filter:level", { 'level_ids[]': level_ids });
        },

        activateInput: function(level_value) {
            this.$('[value=' + level_value + ']').prop('checked', true);
        }
    });
});
