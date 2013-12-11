
/* just a basic marionette view */
FilteredSearch.module('Views.StructuresCollection.Filters', function(Module, App, Backbone, Marionette, $, _) {

    var MAX_AGE = 19;

    Module.AudienceFilterView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'audience_filter_view',
        setup: function (data) {
            this.activateButton(data.audience);
            this.ui.age_picker.hide();

            var $selects = this.ui.age_picker.find('select');

            this.populateAgeSelect($selects, 0, MAX_AGE);
            this.ui.age_picker.find('#max-age').val(MAX_AGE - 1);
        },

        ui: {
            'age_picker': '[data-behaviour=age-picker]'
        },

        events: {
            'change [type="radio"]': 'announceAudience',
            'change select':         'setRangeOptions announceAudience',
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

        announceAudience: function (e, data) {
            var value = e.currentTarget.getAttribute('value'),
                audience = { 'audience': value };

            if (value === "children") {
                audience['min_age_for_kids'] = this.ui.age_picker.find('#min-age').val();
                audience['max_age_for_kids'] = this.ui.age_picker.find('#max-age').val();
            }

            this.trigger("filter:audience", audience);
            this.activateButton(value);
        },

        activateButton: function(data) {
            this.$('[type="radio"]').prop('checked', false);
            this.$('[value=' + data + ']').prop('checked', true);

            if (data === "children") {
                this.ui.age_picker.slideDown();
            } else {
                this.ui.age_picker.slideUp();
            }
        }
    });
});
