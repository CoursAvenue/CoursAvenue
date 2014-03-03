(function ($) {

    // returns an element that has the same height and width as the
    // given element
    $.fn.husk = function (options) {
        var result = this.map(function () {
            var classes = $(this).attr("class");
            var div     = $("<div>")
                             .height(this.offsetHeight)
                             .width(this.offsetWidth).get(0);

            return div;
        });

        return result;
    };

    // attach the stickyness to the given jquery object
    $.fn.sticky = function (options) {

        return this.each(function () {
            // we add a default z-index of 2
            var $element    = $(this).css({ "z-index": (options)? options.sticky || 1 : 1 });
            var sticky_home = -1; // TODO this is still a magic number
            var old_classes = $(this).attr("class");

            $(window).scroll(function () {
                var scroll_top = $(window).scrollTop();
                var element_top = $element.offset().top;
                var fixed = $element.hasClass("sticky");

                if (!fixed && scroll_top >= element_top) {
                    var $placeholder = $element.husk()
                        .css({ visibility: "hidden" })
                        .attr("data-placeholder", "")
                        .attr("data-behavior", "");
                    // we have scrolled past the element
                    var old_width = $element.outerWidth();
                    var old_top   = $element.offset().top;

                    // $placeholder stays behind to hold the place
                    if (options && !options.no_placeholder) {
                        $element.parent().prepend($placeholder);
                    }

                    sticky_home = element_top;
                    $element.removeClass(old_classes);
                    $placeholder.addClass(old_classes);
                    $element.addClass("sticky");
                    $element.css({ width: old_width, margin: 0 });
                } else if ( fixed && scroll_top < sticky_home) {
                    // we have now scrolled back up, and are replacing the element

                    $element.parent().find("[data-placeholder]").remove();
                    $element.removeClass("sticky");
                    $element.addClass(old_classes);
                    $element.css({ width: "", margin: "" });
                    sticky_home = -1;
                }
            });
        });
    };

}( jQuery ));
