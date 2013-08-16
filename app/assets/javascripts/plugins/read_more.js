(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');

    /*
     * Given an element, will truncate the text and put a link
     * giving the oportunity to read more.
     */

    objects.ReadMore = new Class({
        Implements: Options,

        options: {
            text_height: 150,
            read_more_text: 'Lire la suite →',
            read_less_text: 'Cacher'
        },

        initialize: function(el, options) {
            this.el           = el;
            this.el.removeClass('read-more');
            this.original_height = this.el.getHeight();
            this.el.addClass('read-more');
            if (this.original_height > this.options.text_height) {
                this.is_hidden = true;
                this.el.addClass('read-more');
                this.read_more_link = new Element('a', {text: this.options.read_more_text, href: 'javascript:void(0)'});
                this.read_more_link.inject(this.el, 'after');
                this.read_more_link.addEvent('click', function() {
                    if (this.is_hidden) {
                        this.read_more_link.set('text', this.options.read_less_text);
                        this.el.removeClass('read-more');
                    } else {
                        this.read_more_link.set('text', this.options.read_more_text);
                        this.el.addClass('read-more');
                    }
                    this.is_hidden = !this.is_hidden;
                }.bind(this));
            }
        },
    });
})();

$(function() {
    $$('[data-behavior=read-more]').each(function(el) {
        new GLOBAL.Objects.ReadMore(el);
    });
});
