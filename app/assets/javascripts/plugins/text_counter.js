/*
    Usage: TODO
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "textCounter",
        defaults = {
            average_words_nb:   100,
            good_words_nb:      200,
            bad_text:           "Votre texte n'est pas assez long",
            average_text:       'Vous pouvez mieux faire !',
            good_text:          'Super description !'
        };

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
            if (this.$element.data('average-words-nb')) { this.options.average_words_nb = this.$element.data('average-words-nb') };
            if (this.$element.data('good-words-nb'))    { this.options.good_words_nb    = this.$element.data('good-words-nb'); }
            if (this.$element.data('bad-text'))         { this.options.bad_text         = this.$element.data('bad-text'); }
            if (this.$element.data('average-text'))     { this.options.average_text     = this.$element.data('average-text'); }
            if (this.$element.data('good-text'))        { this.options.good_text        = this.$element.data('good-text'); }
            this.text_input = this.$element;
            this.attachEvents();
            this.addInfoDiv();
            this.render();
        },

        addInfoDiv: function addInfoDiv () {
            this.info_div          = $('<div>').addClass('textarea-counter-wrapper');
            this.nb_word_span      = $('<p>').addClass('bold textarea-counter flush--bottom');
            this.nb_word_info_span = $('<p>').addClass('textarea-counter-info flush--top flush--bottom');

            this.info_div.append(this.nb_word_span);
            this.info_div.append(this.nb_word_info_span);

            this.text_input.after(this.info_div);
        },

        attachEvents: function attachEvents () {
            this.text_input.keyup(this.render.bind(this));
        },

        render: function render () {
            var nb_words = this.nbWord();
            if (this.$element.data('characters')) {
                nb_words = this.text_input.val().length;
                this.nb_word_span.text(nb_words + ' caractères');
            } else {
                this.nb_word_span.text(nb_words + ' mots');
            }
            this.nb_word_span.removeClass('red').removeClass('orange').removeClass('green');
            if (nb_words < this.options.average_words_nb) {
              this.nb_word_span.addClass('red');
              this.nb_word_info_span.text(this.options.bad_text);
            } else if (nb_words >= this.options.average_words_nb && nb_words < this.options.good_words_nb) {
              this.nb_word_span.addClass('orange');
              this.nb_word_info_span.text(this.options.average_text);
            } else if (nb_words >= this.options.good_words_nb) {
              this.nb_word_span.addClass('green');
              this.nb_word_info_span.text(this.options.  good_text);
            }
        },

        nbWord: function nbWord () {
            var text  = this.text_input.val(),
                words = text.match(/\S+/g);
            if (words === null ) { words = ''; }
            return words.length;
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
    var textcounter_initializer = function() {
        $('[data-behavior=text-counter]').textCounter();
    };
    GLOBAL.initialize_callbacks.push(textcounter_initializer);
});
