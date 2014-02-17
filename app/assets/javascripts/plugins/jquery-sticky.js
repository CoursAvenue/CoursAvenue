(function ($) {
    /* TODO also, why does it sometimes stop docking? Reproduce this. */

    // attach the stickyness to the given jquery object
    $.fn.sticky = function (options) {

        return this.each(function () {
            // we add a default z-index of 2
            var $element = $(this).css({ "z-index": (options)? options.sticky || 1 : 1 });
            var sticky_home = -1; // TODO this is still a magic number

            $(window).scroll(function () {
                var scroll_top = $(window).scrollTop();
                var element_top = $element.offset().top;
                var fixed = $element.hasClass("sticky");

                if (!fixed && scroll_top >= element_top) {
                    var $placeholder = $element.clone()
                    .css({ visibility: "hidden" })
                    .attr("data-placeholder", "")
                    .attr("data-behavior", "");
                    // we have scrolled past the element

                    var old_width = $element.outerWidth();
                    var old_top   = $element.offset().top;

                    // $placeholder stays behind to hold the place
                    $element.parent().prepend($placeholder);

                    sticky_home = element_top;
                    $element.addClass("sticky");
                    $element.css({ width: old_width, margin: 0 });
                } else if ( fixed && scroll_top < sticky_home) {
                    // we have now scrolled back up, and are replacing the element

                    $element.parent().find("[data-placeholder]").remove();
                    $element.removeClass("sticky");
                    $element.css({ width: "", margin: "" });
                    sticky_home = -1;
                }
            });
        });
    };

}( jQuery ));
