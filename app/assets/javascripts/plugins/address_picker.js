/*
    Usage:
    <input  data-behavior='address-picker'
            data-list='#address-list'
            data-lng='#address-lng'
            data-lat='#address-lat' />
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "addressPicker",
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

        init: function() {
            this.data_list      = $(this.$element.data('list')).hide();
            this.input_lat      = $(this.$element.data('lat'));
            this.input_lng      = $(this.$element.data('lng'));
            this.input_city     = $(this.$element.data('city'));
            if (typeof google !== 'undefined') {
                this.geocoder = new google.maps.Geocoder();
            }
            this.initializePositionOfList();
            this.attachEvents();
        },

        initializePositionOfList: function() {
            this.data_list.css('top', this.element.offsetHeight + "px");
        },

        attachEvents: function() {
            var address_picker = this;
            var data_list      = this.data_list;
            var geocoder       = this.geocoder;

            // ----------------------------- Input blur
            $(document.body).click(function(event) {
                // Hide if not input and list
                if (!$(event.target).hasClass('search-input')
                    && !$(event.target).hasClass('search-input-wrapper')
                    && !$(event.target).hasClass('address-list')) {
                    if (data_list.is(':visible')) {
                        address_picker.selectCurrent(event);
                        data_list.hide();
                    }
                }
            });

            // ----------------------------- Input focus
            this.$element.focus(function(event) {
                if (data_list.children.length > 0) {
                    data_list.show();
                }
            });

            // ----------------------------- Input keyup
            this.$element.keydown(function(event) {
                switch (event.keyCode) {
                    case 13: // Enter
                        this.selectCurrent(event);
                        // Prevent from submitting form
                        if (data_list.is(':visible')) {
                            event.preventDefault();
                            data_list.hide();
                        }
                        break;
                }

            }.bind(this));

            this.$element.keyup(function(event) {
                switch (event.keyCode) {
                    case 13: // Enter
                        break;
                    case 38: // Up
                        this.highlightPrevious();
                        break;
                    case 40: // Down
                        this.highlightNext();
                        break;
                    default:
                        geocoder.geocode({ 'address': 'France, ' + event.target.value, 'region': 'FR' }, function (results, status) {
                            if (results != null) {
                                var addresses = [];
                                $.each(results, function(index, address) {
                                    var li = $('<li>').html(address.formatted_address);
                                    li.data('lat', address.geometry.location.lat());
                                    li.data('lng', address.geometry.location.lng());
                                    // Retrieving city name
                                    var arrAddress = address.address_components;
                                    // iterate through address_component array
                                    $.each(arrAddress, function (i, address_component) {
                                        if (address_component.types[0] == "locality") {// locality type
                                            li.data('city', address_component.long_name);
                                            return false; // break the loop
                                        }
                                    });
                                    li.click(function(event) {
                                        address_picker.select.call(address_picker, this);
                                    });
                                    li.mouseover(function(event) {
                                        address_picker.highlight.call(address_picker, event.target);
                                    });
                                    addresses.push(li);
                                });
                                $.map(data_list.children(), function(li) { li.remove(); });
                                data_list.append(addresses);
                                data_list.show();
                                address_picker.highlightNext();
                            }
                        });
                }
            }.bind(this));
        },

        // Highlight given element
        highlight: function(li_element) {
            this.data_list.children('.selected').removeClass('selected');
            $(li_element).addClass('selected');
        },

        // Highlight previous li item
        highlightPrevious: function() {
            var selected_el, children, next_selected;
            if ((selected_el = this.data_list.children('.selected')).length !== 0) {
                selected_el = selected_el[0];
                if (selected_el.previousSibling) {
                    next_selected = $(selected_el.previousSibling);
                } else {
                    children = this.data_list.children()
                    next_selected = children[children.length - 1];
                }
            } else if ((children = this.data_list.children()).length > 0) {
                next_selected = children[children.length - 1];
            }
            this.highlight(next_selected);
        },

        // Highlight next li item
        highlightNext: function() {
            var selected_el, children, next_selected;
            if ((selected_el = this.data_list.children('.selected')).length !== 0) {
                selected_el = selected_el[0];
                if (selected_el.nextSibling) {
                    next_selected = $(selected_el.nextSibling);
                } else {
                    children = this.data_list.children()[0]
                    next_selected = $(children[0])
                }
                next_selected.addClass('selected');
            } else if ((children = this.data_list.children()).length > 0) {
                next_selected = children[0];
            }
            this.highlight(next_selected);
        },

        // Select the currently highlighted element
        selectCurrent: function(event) {
            var current = this.data_list.children('.selected')[0] || this.data_list.children()[0];
            this.select(current);
        },

        // Select the passed element
        select: function(li_element) {
            var $li_element = $(li_element)
            this.input_lat.val($li_element.data('lat'));
            this.input_lng.val($li_element.data('lng'));
            this.input_city.val($li_element.data('city'));
            this.$element.val($li_element.text());
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
    $('[data-behavior=address-picker]').each(function(index, el) {
        $(this).addressPicker();
    });
});
