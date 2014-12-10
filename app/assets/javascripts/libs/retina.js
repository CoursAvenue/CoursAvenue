//Note: this example assumes jQuery is available on your site.
Retina = function() {
    return {
        init: function(){
            //Get pixel ratio and perform retina replacement
            //Optionally, you may also check a cookie to see if the user has opted out of (or in to) retina support
            var pixelRatio = !!window.devicePixelRatio ? window.devicePixelRatio : 1;
            if (pixelRatio > 1) {
                $("img").each(function(idx, el){
                    el = $(el);
                    if (el.attr("data-src2x")) {
                        el.attr("data-src-orig", el.attr("src"));
                        el.attr("src", el.attr("data-src2x"));
                    }
                });
            }
        }
    };
}();
//Init
Retina.init();
