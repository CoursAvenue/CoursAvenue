(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Updates a given select depending on the zip_code given
     */

    objects.CityAutocomplete = new Class({

        initialize: function(el, options) {
            this.el             = el;
            this.select_element = $(el.get('data-el'));
            this.current_val    = '';
            this.request = new Request.JSON({
                url: '/cities/zip_code_search.json',
                onSuccess: function(cities) {
                    this.select_element.empty();
                    var select_el = this.select_element;
                    cities.cities.each(function(city) {
                        select_el.grab(new Option(city.name, city.id));
                    });
                }.bind(this)
            });
            this.attachEvents();
            if (this.select_element.get('value').length === 0) {
                this.retrieveCity();
            }
        },

        attachEvents: function() {
            var select = this.select_element;
            this.el.addEvent('keyup', this.retrieveCity.bind(this));
        },
        retrieveCity: function() {
            if (this.el.value.length === 5 && this.current_val !== this.el.value) {
                this.request.cancel();
                this.current_val = this.el.value;
                this.request.get('term=' + this.el.value);
            }
        }
    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=city-autocomplete]').each(function(el) {
        new GLOBAL.Objects.CityAutocomplete(el);
    });
});
