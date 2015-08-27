/*
 * Attach the stickyness to the given jquery object
 * Usage:
 *    <div data-behavior="sticky"> // Options can be passed in html data
 *
 * Options:
 *      offsetTop: Integer offset top from where the sticky has to stick
 *      z:         Integer z-index
 *      oldWidth:  Will apply old width as style
 *      onStick:   Function callback called when stick class is added
 *      onUnStick: Function callback called when stick class is removed
 *      stopAtEl:  When arriving at the bottom of that div, unfix
 */
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "sticky",
        defaults = {
            scrollContainer: window,
            offsetTop      : 0,
            z              : 1300,
            oldWidth       : false,
            oldHeight      : true,
            onStick        : $.noop,
            onUnStick      : $.noop,
            stopAtEl       : null, // '#coursavenue-footer',
            stopAtWrapperEl: null, // '#coursavenue-footer',
            updateOnScroll : false
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
        husk: function husk ($element) {
            var self = this;
            var result = $element.map(function () {
                var classes = $element.attr("class");
                var div     = $("<div>");
                if (self.options.oldHeight != 'false' && self.options.oldHeight != false) {
                    div.height($element[0].offsetHeight);
                } else {
                    div.height($(window).height() + 50);
                }
                div.width($element[0].offsetWidth);

                return div.get(0);
            });

            return result;
        },

        init: function init () {
            this.$element.css({ "z-index": this.options.z });
            this.sticky_home   = -1; // TODO this is still a magic number
            this.old_classes   = this.$element.attr("class");
            this.old_top       = this.$element.offset().top;
            $(this.options.scrollContainer).scroll(this.onScroll.bind(this));
            this.calculateElementTop();
            setTimeout(function() {
                if (this.options.pushed) {
                    this.$pusher_el    = $(this.options.pushed);
                    this.pusher_height = this.$pusher_el.outerHeight();
                }
            }.bind(this));
        },

        calculateElementTop: function calculateElementTop () {
            this.element_top = this.$element.offset().top
            if (this.options.scrollContainer != window) { this.element_top -= $(this.options.scrollContainer).offset().top; }
        },

        onScroll: function onScroll () {
            if (this.options.updateOnScroll) { this.calculateElementTop(); this.calculateStopAtHeight(); }
            this.scroll_top  = $(this.options.scrollContainer).scrollTop();
            this.fixed       = this.$element.hasClass("sticky");

            if (this.options.stopAtWrapperHeight && this.scroll_top > this.options.stopAtWrapperHeight ) {
                this.unFixIt();
            } else if (this.options.stopAtHeight && (this.scroll_top + this.$element.height() + this.options.offsetTop > this.options.stopAtHeight)) {
                this.$element.css('top', -(this.scroll_top + this.$element.height() - this.options.stopAtHeight));
            } else if (this.options.pushed) {
                this.fixAndPush();
            } else if ( !this.fixed && this.scroll_top >= (this.element_top - this.options.offsetTop) ) {
                this.fixIt();
            // we have now scrolled back up, and are replacing the element
            } else if ( this.fixed && this.scroll_top < (this.sticky_home - this.options.offsetTop)) {
                this.unFixIt();
            }
        },
        unFixIt: function unFixIt () {
            this.$element.css('top', 0);
            this.$element.parent().find("[data-sticky-placeholder]").remove();
            this.$element.removeClass("sticky");
            this.$element.addClass(this.old_classes);
            this.$element.css({ width: "", margin: "" });
            this.sticky_home = -1;
            this.options.onUnStick(this.$element);
        },

        fixIt: function fixIt () {
            this.calculateStopAtHeight()
            this.calculateStopAtWrapperHeight()
            var $placeholder = this.husk(this.$element)
                .css({ visibility: "hidden" })
                .attr("data-sticky-placeholder", "")
                .attr("data-behavior", "");
            // we have scrolled past the element
            var old_top   = this.$element.offset().top;

            // $placeholder stays behind to hold the place
            if (this.options) {
                this.$element.parent().prepend($placeholder);
            }

            this.sticky_home = this.element_top;
            this.$element.removeClass(this.old_classes);
            $placeholder.addClass(this.old_classes);
            this.$element.addClass("sticky");
            this.$element.addClass(this.old_classes);

            if (this.options.oldWidth) {
                this.$element.css('width', $placeholder.outerWidth() + 'px');
            }
            this.$element.css('top', this.options.offsetTop + 'px');
            this.options.onStick(this.$element);
        },

        fixAndPush: function fixAndPush () {
            // Pusher element is the element on top that will push the current element.
            // When coming down and pusher element hit the current element
            if ( !this.fixed &&
                 this.scroll_top >= (this.element_top - this.options.offsetTop - this.pusher_height) &&
                 this.scroll_top <= (this.element_top - this.options.offsetTop)) {
                this.$pusher_el.css('margin-top', - (this.pusher_height - (this.$element.offset().top - this.scroll_top - this.options.offsetTop)));
            } else if ( !this.fixed && this.scroll_top >= (this.element_top - this.options.offsetTop) ) {
                this.fixIt();
            } else if ( this.fixed && this.scroll_top < (this.sticky_home - this.options.offsetTop)) {
                this.unFixIt();
            } else if (this.$pusher_el) {
                this.$pusher_el.css('margin-top', 0);
            }
        },

        /*
         * User can pass a stopAtEl which indicates where to stop fixing
         * Calculate it when element is being fixed to be sure the dom hasn't
         * changed and the height of the page neither
         */
        calculateStopAtHeight: function calculateStopAtHeight () {
            if (this.options.stopAtEl == null) { return; }
            if (!this.$stopAtEl) { this.$stopAtEl = $(this.options.stopAtEl) }
            this.options.stopAtHeight = this.$stopAtEl.offset().top;
        },

        calculateStopAtWrapperHeight: function calculateStopAtWrapperHeight () {
            if (this.options.stopAtWrapperEl == null) { return; }
            if (!this.$stopAtWrapperEl) { this.$stopAtWrapperEl = $(this.options.stopAtWrapperEl) }
            this.options.stopAtWrapperHeight = $(this.options.stopAtWrapperEl).height() + $(this.options.stopAtWrapperEl).offset().top;
            this.options.stopAtWrapperHeight = this.options.stopAtWrapperHeight - this.options.offsetTop - this.$element.outerHeight();
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
