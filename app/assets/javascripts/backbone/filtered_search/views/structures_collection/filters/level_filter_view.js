
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
            this.announceBreadcrumb();
        },

        // Clears all the given filters
        clear: function () {
            _.each(this.ui.$buttons.find('input'), function(input) {
                var $input = $(input);
                $input.prop("checked", false);
                $input.parent('.btn').removeClass('active');
            });
            this.announce();
        },

        ui: {
            '$buttons': '[data-toggle=buttons]'
        },

        events: {
            'change input': 'announce'
        },

        announce: function (e, data) {
            var level_ids = _.map(this.$('[name="level_ids[]"]:checked'), function(input){ return input.value });
            this.trigger("filter:level", { 'level_ids[]': level_ids });
            this.announceBreadcrumb(level_ids);
        },

        announceBreadcrumb: function(level_ids) {
            var title;
            level_ids = level_ids || _.map(this.$('[name="level_ids[]"]:checked'), function(input){ return input.value });
            if (level_ids.length === 0) {
                this.trigger("filter:breadcrumb:remove", {target: 'level'});
            } else {
                title = _.map(this.$('[name="level_ids[]"]:checked'), function(input){ return $(input).parent().text().trim() });
                this.trigger("filter:breadcrumb:add", {target: 'level', title: title.join(', ')});
            }
        },

        activateInput: function(level_value) {
             var $input = this.$('[value=' + level_value + ']');
            $input.prop('checked', true);
            $input.parent('.btn').addClass('active');
        }
    });
});
