
(function ($) {
    /* TODO also, why does it sometimes stop docking? Reproduce this. */
    // attach the stickyness to the given jquery object
    $.fn.sticky = function (options) {

        return this.each(function () {
            var $element = $(this);
            var sticky_home = -1;
            var $placeholder = $element.clone()
            .css({ visibility: "hidden" })
            .attr("data-placeholder", "")
            .attr("data-behavior", "");

            $(window).scroll(function () {
                var scroll_top = $(window).scrollTop();
                var element_top = $element.offset().top;
                var fixed = $element.hasClass("sticky");

                if (!fixed && scroll_top >= element_top) {
                    // we have scrolled past the element

                    var old_width = $element.width();

                    // $placeholder stays behind to hold the place
                    $element.parent().prepend($placeholder);

                    sticky_home = element_top;
                    $element.addClass("sticky");
                    $element.css({ width: old_width });
                } else if ( fixed && scroll_top < sticky_home) {
                    // we have now scrolled back up, and are replacing the element

                    $placeholder.remove();
                    $element.removeClass("sticky");
                    $element.css({ width: "" });
                    sticky_home = -1;
                }
            });

        });
    };

}( jQuery ));
