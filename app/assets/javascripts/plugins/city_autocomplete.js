/*
    Usage:
    <input data-behavior='city-autocomplete'
           data-el='#input-to-complete'/>
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "cityAutocomplete",
        defaults = {};

    // The actual plugin constructor
    function Plugin( element, options ) {
        this.element  = element;
        this.$element = $(element);

        // jQuery has an extend method that merges the
        // contents of two or more objects, storing the
        // result in the first object. The first object
        // is generally empty because we don't want to alter
        // the default options for future instances of the plugin
        this.options = $.extend( {}, defaults, options) ;

        this._defaults = defaults;
        this._name = pluginName;

        this.init();
    }

    Plugin.prototype = {

        init: function init () {
            this.select_element = $(this.$element.data('el'));
            this.current_val    = '';
            this.attachEvents();
            if (_.isEmpty(this.select_element.val())) {
                this.retrieveCity();
            }
        },

        attachEvents: function attachEvents () {
            var select = this.select_element;
            this.$element.keyup(this.retrieveCity.bind(this));
        },
        retrieveCity: function retrieveCity () {
            if (this.element.value.length === 5 && this.current_val !== this.element.value) {
                if (this.request) { this.request.abort(); }
                this.current_val = this.element.value;
                var value = this.element.value;
                this.request = $.ajax({
                    url: Routes.zip_code_search_admin_cities_path({format: 'json'}),
                    dataType: 'json',
                    data: {
                        term: value
                    },
                    success: function success (cities) {
                        this.select_element.empty();
                        var select_el = this.select_element;
                        $.each(cities, function(index, city) {
                            select_el.append(new Option(city.name, city.id));
                        });
                    }.bind(this)
                });

            }
        }
    };
    // A really lightweight plugin wrapper around the constructor,
    // preventing against multiple instantiations
    $.fn[pluginName] = function ( options ) {
        return this.each(function () {
            if (!$.data(this, "plugin_" + pluginName)) {
                $.data(this, "plugin_" + pluginName,
                new Plugin( this, options ));
            }
        });
    }

})( jQuery, window, document );

$(function() {
    var city_autocomplete_initializer = function() {
        $('[data-behavior=city-autocomplete]').cityAutocomplete();
    };
    COURSAVENUE.initialize_callbacks.push(city_autocomplete_initializer);
});
