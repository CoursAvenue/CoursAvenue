(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     */


    objects.AddressPicker = new Class({

        initialize: function(el, options) {
            this.el             = el;
            this.data_list      = $(el.get('data-list')).hide();
            this.input_lat      = $(el.get('data-lat'));
            this.input_lng      = $(el.get('data-lng'));
            if (typeof google !== 'undefined') {
                this.geocoder       = new google.maps.Geocoder();
            }
            this.initializePositionOfList();
            this.attachEvents();
        },

        initializePositionOfList: function() {
            this.data_list.setStyle('top', this.el.offsetHeight + "px");
        },

        attachEvents: function() {
            var address_picker = this;
            var data_list      = this.data_list;
            var geocoder       = this.geocoder;

            // ----------------------------- Input blur
            document.body.addEvent('click', function(event) {
                // Hide if not input and list
                if (!event.target.match('.search-input')
                    && !event.target.match('.search-input-wrapper')
                    && !event.target.match('.address-list')) {
                    if (data_list.isVisible()) {
                        address_picker.selectCurrent(event);
                        data_list.hide();
                    }
                }
            });

            // ----------------------------- Input focus
            this.el.addEvent('focus', function(event) {
                if (data_list.children.length > 0) {
                    data_list.show();
                }
            });

            // ----------------------------- Input keyup
            this.el.addEvent('keydown', function(event) {
                switch (event.code) {
                    case 13: // Enter
                        this.selectCurrent(event);
                        // Prevent from submitting form
                        if (data_list.isVisible()) {
                            event.stop();
                            data_list.hide();
                        }
                        break;
                }

            }.bind(this));

            this.el.addEvent('keyup', function(event) {
                switch (event.code) {
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
                                results.each(function(address){
                                    var li = new Element('li', {
                                        html: address.formatted_address,
                                        'data-lat': address.geometry.location.lat(),
                                        'data-lng': address.geometry.location.lng(),
                                        class: 'address-list__item',
                                        events: {
                                            click: function(event) {
                                                address_picker.select.call(address_picker, this);
                                            },
                                            mouseover: function(event) {
                                                address_picker.highlight.call(address_picker, event.target);
                                            }
                                        }
                                    });
                                    addresses.push(li);
                                });
                                data_list.getChildren().map(function(li) { li.dispose(); });
                                data_list.adopt(addresses);
                                data_list.show();
                                address_picker.highlightNext();
                            }
                        });
                }
            }.bind(this));
        },

        // Highlight given element
        highlight: function(li_element) {
            this.data_list.getChildren('.selected').removeClass('selected');
            li_element.addClass('selected');
        },

        // Highlight previous li item
        highlightPrevious: function() {
            var selected_el, children, next_selected;
            if ((selected_el = this.data_list.getChildren('.selected')).length !== 0) {
                selected_el = selected_el[0];
                if (selected_el.previousSibling) {
                    next_selected = selected_el.previousSibling;
                } else {
                    children = this.data_list.children
                    next_selected = children[children.length - 1];
                }
            } else if ((children = this.data_list.children).length > 0) {
                next_selected = children[children.length - 1];
            }
            this.highlight(next_selected);
        },

        // Highlight next li item
        highlightNext: function() {
            var selected_el, children, next_selected;
            if ((selected_el = this.data_list.getChildren('.selected')).length !== 0) {
                selected_el = selected_el[0];
                if (selected_el.nextSibling) {
                    next_selected = selected_el.nextSibling;
                } else {
                    children = this.data_list.children
                    next_selected = children[0]
                }
                next_selected.addClass('selected');
            } else if ((children = this.data_list.children).length > 0) {
                next_selected = children[0];
            }
            this.highlight(next_selected);
        },

        // Select the currently highlighted element
        selectCurrent: function(event) {
            var current = this.data_list.getChildren('.selected')[0] || this.data_list.getChildren()[0];
            this.select(current);
        },

        // Select the passed element
        select: function(li_element) {
            this.input_lat.set('value', li_element.get('data-lat'));
            this.input_lng.set('value', li_element.get('data-lng'));
            this.el.set('value', li_element.get('text'));
        }

    });
})();

// Initialize all input-update objects
window.addEvent('domready', function() {
    $$('[data-behavior=address-picker]').each(function(el) {
        new GLOBAL.Objects.AddressPicker(el);
    });
});
