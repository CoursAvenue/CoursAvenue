(function() {
    'use strict';
    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an input element, will update a relative element.
     */

    objects.Price = new Class({

        Implements: Options,

        options: {
            el: 'prices',
            price_template_el: 'price-template'
        },

        /*
         * Loads handlbars template associated to the view and associated elements
        */
        loadTemplatesAndElements: function() {
            this.price_template = Handlebars.compile($(this.options.price_template_el).get('html'));
            this.el = $(this.options.el);
        },

        initialize: function(price, options) {
            this.setOptions(options);
            this.loadTemplatesAndElements();

            this.price = price;
        },

        render: function() {
            this.el.set('html', this.price_template());
        }
    });
})();
