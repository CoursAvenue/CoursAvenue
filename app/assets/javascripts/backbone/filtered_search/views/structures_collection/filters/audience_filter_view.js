
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    var MAX_AGE = 19;

    Module.AudienceFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'audience_filter_view',
        setup: function (data) {
            var self = this;
            _.each(data.audience_ids, function(audience_id) {
                self.activateInput(audience_id);
            });
            if (this.isChild(data.audience_ids)) {
                this.ui.age_picker.show();
            } else {
                this.ui.age_picker.hide();
            }

            var $selects = this.ui.age_picker.find('select');

            this.populateAgeSelect($selects, 0, MAX_AGE);
            this.ui.age_picker.find('#max-age').val(MAX_AGE - 1);
            this.ui.min_age_select.val(data.min_age_for_kids || 0);
            this.ui.max_age_select.val(data.max_age_for_kids || MAX_AGE);
        },

        ui: {
            'age_picker'    : '[data-behavior=age-picker]',
            'min_age_select': '#min-age',
            'max_age_select': '#max-age'
        },

        events: {
            'change input':   'announce',
            'change select':  'setRangeOptions announce'
        },

        setRangeOptions: function (e) {
            var $select = this.ui.age_picker.find('select:not(#' + e.currentTarget.id + ')'),
                age_1 = e.currentTarget.value, min, max;

            if ($select.attr('id') !== 'min-age') {
                min = parseInt(age_1, 10);
                max = MAX_AGE;
            } else {
                min = 0;
                max = parseInt(age_1, 10) + 1; // MAX_AGE is a closed limit
            }

            this.populateAgeSelect($select, min, max);
        },

        populateAgeSelect: function ($select, min, max) {
            var val = $select.val() || 0;
            $select.empty();

            _.times((max - min), function (index) {
                $select.append('<option value=' + (min + index) + '>' + (min + index) + '</option>');
            });

            // if the select value is still in [min, max), apply it
            if (min <= val && val < max) {
                $select.val(val);
            } else {
                ($select.attr('id') === 'min-age')? $select.val(min) : $select.val(max);
            }
        },

        announce: function (e) {
            var audience_ids, value_to_trigger = {};

            audience_ids = _.map(this.$('[name="audience_ids[]"]:checked'), function(input){ return input.value });
            value_to_trigger['audience_ids[]'] = audience_ids;

            // 1 is children
            if (this.isChild(audience_ids)) {
                this.ui.age_picker.slideDown();
                value_to_trigger['min_age_for_kids'] = this.ui.age_picker.find('#min-age').val();
                value_to_trigger['max_age_for_kids'] = this.ui.age_picker.find('#max-age').val();
            } else {
                this.ui.age_picker.slideUp();
            }

            this.trigger("filter:audience", value_to_trigger);
        },

        activateInput: function (audience_id) {
            this.$('[value=' + audience_id + ']').prop('checked', true);

        },

        isChild: function (audience_id) {
            if (_.isArray(audience_id)) {
                return audience_id.indexOf('1') !== -1;
            } else {
                return audience_id === '1';
            }
        }
    });
});
