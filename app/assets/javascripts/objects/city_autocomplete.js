(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.CityAutocomplete = new Class({

        initialize: function(el, options) {
            this.el             = el;
            this.select_element = $(el.get('data-el'));
            this.current_val    = el.get('value');
            this.request = new Request.JSON({
                url: Routes.cities_path({format: 'json'}),
                onSuccess: function(cities) {
                    this.select_element.empty();
                    var select_el = this.select_element;
                    cities.cities.each(function(city) {
                        select_el.grab(new Option(city.name, city.id));
                    });
                }.bind(this)
            });
            this.attachEvents();
        },

        attachEvents: function() {
            var select = this.select_element;
            this.el.addEvent('keyup', function(event) {
                if (event.target.value.length > 2 && this.current_val !== event.target.value) {
                    this.current_val    = this.el.get('value');
                    this.request.cancel();
                    this.request.get('term=' + event.target.value);
                }
            }.bind(this));
        }
    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=city-autocomplete]').each(function(el) {
        new GLOBAL.Objects.CityAutocomplete(el);
    });
});
