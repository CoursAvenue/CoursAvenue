
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.LevelFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'level_filter_view',

        initialize: function() {
            this.announce = _.debounce(this.announce, 800);
        },

        setup: function (data) {
            var self = this;
            _.each(data.level_ids, function(level_id) {
                self.activateInput(level_id);
            });
        },

        /* clears all the given filters */
        clear: function (filters) {
            filters = [0, 1];
            var self = this;

            _.each(filters, function (filter) {
                var input = self.ui.$buttons.find('[value="' + filter + '"]');
                input.prop("checked", false);
                input.parent('.btn').removeClass('active');
            });

            this.announce();
        },

        ui: {
            '$buttons': '[data-toggle=buttons]'
        },

        events: {
            'change input': 'announce',
            'click [data-type=bob]': 'clear'
        },

        announce: function (e, data) {
            var level_ids = _.map(this.$('[name="level_ids[]"]:checked'), function(input){ return input.value });
            this.trigger("filter:level", { 'level_ids[]': level_ids });
        },

        activateInput: function(level_value) {
             var $input = this.$('[value=' + level_value + ']');
            $input.prop('checked', true);
            $input.parent('.btn').addClass('active');
        }
    });
});
