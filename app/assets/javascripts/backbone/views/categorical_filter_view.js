FilteredSearch.module('Views', function(Views, App, Backbone, Marionette, $, _) {

    Views.CategoricalFilterView = Backbone.Marionette.ItemView.extend({
        template: 'backbone/templates/categorical_filter_view',

        initialize: function () {
            this.announceSubject = _.debounce(this.announceSubject, 500);
            this.announceLocation = _.debounce(this.announceLocation, 500);
        },

        events: {
            'typeahead:selected #search-input': 'announceSubject',
            'keypress #search-input': 'announceSubject',
            'typeahead:selected #address-picker': 'announceLocation'
        },

        announceLocation: function (e, data) {
            App.renameProperty(data, 'address', 'address_name');
            App.renameProperty(data, 'latitude', 'lat');
            App.renameProperty(data, 'longitude', 'lng');

            this.trigger("filter:location", data);
        },

        announceSubject: function (e, data) {
            name = (data === undefined) ? e.currentTarget.value : data.name;
            this.trigger("filter:subject", { 'name': name });
        },

        ui: {
            $search_input: '#search-input',
            $address_picker: '#address-picker'
        },

        onRender: function () {
            this.ui.$search_input.typeahead([{
                name: 'subjects' + this.cid,
                valueKey: 'name',
                prefetch: {
                    url: '/disciplines.json'
                },
                header: '<div class="typeahead-dataset-header">Disciplines</div>'
            }]);
        },

        resetCategoricalFilterTool: function (data) {
            this.current_summary_data = data;

            this.ui.$search_input.attr('value', data.name);
            this.ui.$address_picker.attr('value', data.address_name);
        }
    });
});
