/*
*   Usage:
*       %p.read-more{ data: { behavior: 'read-more', height: 100 } }
*         your long text
*   Options:
*       Height: integer
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "readMore",
        defaults = {
            text_height: 145,
            read_more_text: '+ Plus'
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

        init: function() {
            this.$element.removeClass('read-more');
            if (this.$element.data('read_more_text')) { this.options.read_more_text = this.$element.data('read_more_text') }
            this.original_height = this.$element.outerHeight();
            this.$element.addClass('read-more');
            if(this.$element.data('height')) {
                this.options.text_height = this.$element.data('height');
            }
            this.$element.css('max-height', this.options.text_height + 'px');
            if (this.original_height > this.options.text_height) {
                this.$element.addClass('read-more transition-all-500');
                this.read_more_link = $('<a>').text(this.options.read_more_text).attr('href','javascript:void(0)');
                this.expandable_indicator = $('<div>').addClass('expandable-indicator');
                this.$element.append(this.expandable_indicator);
                this.$element.after(this.read_more_link);
                this.read_more_link.click(function() {
                    this.$element.css('max-height', this.original_height + 'px');
                    this.$element.find('.expandable-indicator').remove();
                    this.read_more_link.remove();
                    _.delay(function() {
                        this.$element.css('max-height', 'none');
                    }.bind(this), 500)
                }.bind(this));
            }
            if (this.original_height == 0) {
                this.$element.css('max-height', 'none');
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
    var readmore_initializer = function() {
        $('[data-behavior=read-more]').readMore();
    };
    COURSAVENUE.initialize_callbacks.push(readmore_initializer);
});
