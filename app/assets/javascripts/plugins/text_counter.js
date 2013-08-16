(function() {
    'use strict';

    var objects = GLOBAL.namespace('GLOBAL.Objects');


    /*
     * <textarea data-behaveior="text-counter"
                 data-average-words-nb=50
                 data-good-words-nb=100
                 data-bad-text="Mauvais text"
                 data-average-text="Peut mieux faire !"
                 data-good-text="Top !">
     */

    objects.TextCounter = new Class({
        Implements: Options,

        options: {
            average_words_nb:   100,
            good_words_nb:      200,
            bad_text:           "Votre texte n'est pas assez long",
            average_text:       'Vous pouvez mieux faire !',
            good_text:          'Super description !'
        },

        initialize: function(el, options) {
            this.setOptions(options);
            this.text_input = el;
            this.attachEvents();
            this.addInfoDiv();
            this.render();
        },

        addInfoDiv: function() {
            this.info_div          = new Element('.textarea-counter');
            this.nb_word_span      = new Element('p.bold.textarea-counter.flush--bottom');
            this.nb_word_info_span = new Element('p.textarea-counter-info.flush--top.flush--bottom');

            this.info_div.grab(this.nb_word_span);
            this.info_div.grab(this.nb_word_info_span);

            this.info_div.inject(this.text_input, 'after');
        },

        attachEvents: function() {
            this.text_input.addEvent('keyup', this.render.bind(this))
        },

        render: function() {
            var nb_words = this.nbWord();
            this.nb_word_span.set('text', nb_words + ' mots');
            this.nb_word_span.removeClass('red').removeClass('orange').removeClass('green');
            if (nb_words < this.options.average_words_nb) {
              this.nb_word_span.addClass('red');
              this.nb_word_info_span.set('text', this.options.bad_text);
            } else if (nb_words >= this.options.average_words_nb && nb_words < this.options.good_words_nb) {
              this.nb_word_span.addClass('orange');
              this.nb_word_info_span.set('text', this.options.average_text);
            } else if (nb_words >= this.options.good_words_nb) {
              this.nb_word_span.addClass('green');
              this.nb_word_info_span.set('text', this.options.  good_text);
            }
        },

        nbWord: function() {
            var text  = this.text_input.value,
                words = text.match(/\S+/g);
            if (words === null ) { words = ''; }
            return words.length;
        }
    });
})();

// Initialize all input-update objects
$(function() {
    $$('[data-behavior=text-counter]').each(function(el) {
        options = {};
        if (el.get('data-average-words-nb')) { options.average_words_nb = el.get('data-average-words-nb') };
        if (el.get('data-good-words-nb'))    { options.good_words_nb    = el.get('data-good-words-nb'); }
        if (el.get('data-bad-text'))         { options.bad_text         = el.get('data-bad-text'); }
        if (el.get('data-average-text'))     { options.average_text     = el.get('data-average-text'); }
        if (el.get('data-good-text'))        { options.good_text        = el.get('data-good-text'); }
        new GLOBAL.Objects.TextCounter(el, options);
    });
});
