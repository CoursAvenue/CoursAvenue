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
            this.geocoder       = new google.maps.Geocoder();
            this.initializePositionOfList();
            this.attachEvents();
            $('header-search').addEvent('submit', function(event) {
                if (this.data_list.isVisible()) {
                    event.stop();
                    return false;
                }
            }.bind(this));
        },

        initializePositionOfList: function() {
            this.data_list.setStyle('top', this.el.offsetHeight + "px");
        },

        attachEvents: function() {
            var address_picker = this;
            var data_list      = this.data_list;
            var geocoder       = this.geocoder;

            // ----------------------------- Input blur
            this.el.addEvent('blur', function(event) {
                setTimeout(function(){
                    data_list.hide();
                }, 50);
            });

            // ----------------------------- Input focus
            this.el.addEvent('focus', function(event) {
                if (data_list.children.length > 0) {
                    data_list.show();
                }
            });

            // ----------------------------- Input keyup
            this.el.addEvent('keyup', function(event) {
                switch (event.code) {
                    case 13: // Enter
                        this.selectCurrent(event);
                        break;
                    case 38: // Up
                        this.selectPrevious();
                        break;
                    case 40: // Down
                        this.selectNext();
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
                                        events: {
                                            click: function(event) {
                                                address_picker.select.call(address_picker, this);
                                            }
                                        }
                                    });
                                    addresses.push(li);
                                });
                                data_list.getChildren().map(function(li) { li.dispose(); });
                                data_list.adopt(addresses);
                                data_list.show();
                            }
                        });
                }
            }.bind(this));
        },
        selectPrevious: function() {
            var selected_el, children;
            if ((selected_el = this.data_list.getChildren('.selected')).length !== 0) {
                selected_el = selected_el[0]
                selected_el.removeClass('selected');
                if (selected_el.previousSibling) {
                    selected_el.previousSibling.addClass('selected');
                } else {
                    children = this.data_list.children
                    children[children.length - 1].addClass('selected');
                }
            } else if ((children = this.data_list.children).length > 0) {
                children[children.length - 1].addClass('selected');
            }
        },

        selectNext: function() {
            var selected_el, children;
            if ((selected_el = this.data_list.getChildren('.selected')).length !== 0) {
                selected_el = selected_el[0]
                selected_el.removeClass('selected');
                if (selected_el.nextSibling) {
                    selected_el.nextSibling.addClass('selected');
                } else {
                    children = this.data_list.children
                    children[0].addClass('selected');
                }
            } else if ((children = this.data_list.children).length > 0) {
                children[0].addClass('selected');
            }
        },

        selectCurrent: function(event) {
            var current = this.data_list.getChildren('.selected')[0] || this.data_list.getChildren()[0];
            if (this.data_list.isVisible()) {
                event.stop();
                this.select(current);
                this.data_list.hide();
                return false;
            }
        },

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
