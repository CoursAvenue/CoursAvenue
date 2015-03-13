
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    Module.LevelFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'level_filter_view',

        setup: function setup (data) {
            _.each(data.level_ids, function(level_id) {
                this.activateInput(level_id);
            }, this);
            this.setButtonState();
        },

        ui: {
            '$buttons'             : '[data-toggle=buttons]',
            '$clear_filter_button' : '[data-behavior=clear-filter]',
            '$clearer'             : '[data-el=clearer]'
        },

        events: {
            'change input'                  : 'announce',
            'click @ui.$clear_filter_button': 'clear'
        },

        announce: function announce (e, data) {
            var level_ids = _.map(this.$('[name="level_ids[]"]:checked'), function(input){ return input.value });
            this.trigger("filter:level", { 'level_ids[]': level_ids });
            this.setButtonState(level_ids);
        }.debounce(COURSAVENUE.constants.DEBOUNCE_DELAY),

        /*
         * Set the state of the button, wether or not there are filters or not
         */
        setButtonState: function setButtonState (level_ids) {
            level_ids = level_ids || _.map(this.$('[name="level_ids[]"]:checked'), function(input){ return input.value });
            if (level_ids.length > 0) {
                this.ui.$clearer.show();
                this.ui.$clear_filter_button.removeClass('btn--gray');
            } else {
                this.ui.$clearer.hide();
                this.ui.$clear_filter_button.addClass('btn--gray');
            }
        },

        activateInput: function activateInput (level_value) {
            var $input = this.$('[value=' + level_value + ']');
            $input.prop('checked', true);
            $input.parent('.btn').addClass('active');
        },

        // Clears all the given filters
        clear: function clear () {
            _.each(this.ui.$buttons.find('input'), function(input) {
                var $input = $(input);
                $input.prop("checked", false);
                $input.parent('.btn').removeClass('active');
            });
            this.announce();
        }
    });
});
