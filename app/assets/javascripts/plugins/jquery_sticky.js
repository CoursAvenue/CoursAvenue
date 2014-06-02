/*
 * Attach the stickyness to the given jquery object
 * Options:
 *      offsetTop: Integer offset top from where the sticky has to stick
 *      z:         Integer z-index
 *      onStick:   Function callback called when stick class is added
 *      onUnStick: Function callback called when stick class is removed
 */
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "sticky",
        defaults = {
            offsetTop : 0,
            z         : 300,
            onStick   : $.noop,
            onUnStick : $.noop
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

        /*
         * Returns an element that has the same height and width as the given element
         * Will be used for replacing sticked element in order to not break
         * all the existing layout
         */
        husk: function ($element) {
            var result = $element.map(function () {
                var classes = $element.attr("class");
                var div     = $("<div>")
                                 .height($element[0].offsetHeight)
                                 .width($element[0].offsetWidth).get(0);

                return div;
            });

            return result;
        },

        init: function init () {
            this.$element.css({ "z-index": this.options.z });
            this.sticky_home = -1; // TODO this is still a magic number
            this.old_classes = this.$element.attr("class");

            $(window).scroll(this.onScroll.bind(this));
        },
        onScroll: function onScroll () {
            var scroll_top = $(window).scrollTop();
            var element_top = this.$element.offset().top;
            var fixed = this.$element.hasClass("sticky");

            if (!fixed && scroll_top >= (element_top - this.options.offsetTop)) {
                var $placeholder = this.husk(this.$element)
                    .css({ visibility: "hidden" })
                    .attr("data-placeholder", "")
                    .attr("data-behavior", "");
                // we have scrolled past the element
                var old_top   = this.$element.offset().top;

                // $placeholder stays behind to hold the place
                if (this.options) {
                    this.$element.parent().prepend($placeholder);
                }

                this.sticky_home = element_top;
                this.$element.removeClass(this.old_classes);
                $placeholder.addClass(this.old_classes);
                this.$element.addClass("sticky");
                this.$element.addClass(this.old_classes);

                this.$element.css('top', this.options.offsetTop + 'px');
                this.options.onStick();
            } else if ( fixed && scroll_top < (this.sticky_home - this.options.offsetTop)) {
                // we have now scrolled back up, and are replacing the element

                this.$element.parent().find("[data-placeholder]").remove();
                this.$element.removeClass("sticky");
                this.$element.addClass(this.old_classes);
                this.$element.css({ width: "", margin: "" });
                this.sticky_home = -1;
                this.options.onUnStick();
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
