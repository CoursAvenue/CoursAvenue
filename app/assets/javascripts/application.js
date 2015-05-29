//= require dot-env
//= require libs/underscore
//= require underscore_extend
//= require global
//= require helpers

// ---------------------------------- Core include
//= require libs/jquery
//= require jquery_ujs
//= require libs/jquery-ui-1.10.3.custom
//= require js-routes

// ---------------------------------- Lib includes
//= require libs/handlebars
//= require libs/handlebars-helpers
//= require libs/chosen.jquery
//= require libs/jquery.cookie
//= require libs/typeahead
//= require libs/jquery.fileupload/vendor/jquery.ui.widget
//= require libs/jquery.fileupload/jquery.iframe-transport
//= require libs/jquery.fileupload/jquery.fileupload
//= require libs/jquery.fileupload/jquery.fileupload-process
//= require libs/jquery.fileupload/jquery.fileupload-validate
//= require libs/jquery.fileupload/jquery.fileupload-image
//= require libs/jquery.scrollTo
//= require libs/jquery.nouislider
//= require libs/responsiveslides
//= require libs/jquery.placeholder
//= require libs/imagesloaded.pkgd
//= require libs/jquery.payment

//= require libs/jquery.magnific-popup
//= require libs/jquery.lazyload
//= require libs/fancybox/jquery.fancybox

//= require libs/fingerprint
//= require libs/countdown
//= require libs/redactor/redactor
//= require libs/redactor/langs/fr
//= require libs/redactor/redactor.imagemanager
//= require libs/redactor/redactor.video

//= require_tree ./libs/fancybox/helpers/

//---- Bootstrap plugins
//= require libs/bootstrap/bootstrap.transition
//= require libs/bootstrap/bootstrap.collapse
//= require libs/bootstrap/bootstrap.tooltip
//= require libs/bootstrap/bootstrap.tooltip.overrides
//= require libs/bootstrap/bootstrap.popover
//= require libs/bootstrap/bootstrap.tab
//= require libs/bootstrap/bootstrap.datepicker
//= require libs/bootstrap/bootstrap.button
//= require libs/bootstrap/bootstrap.scrollspy
//= require libs/bootstrap/datepicker-locales/bootstrap.datepicker.fr
//= require libs/moment
//= require libs/retina
//= require libs/masonry.pkgd

// ---------------------------------- jQuery plugins
// See boilerplate and pattern:
// - http://jqueryboilerplate.com/
// - https://github.com/jquery-boilerplate/jquery-patterns/
// - https://github.com/jquery-boilerplate/jquery-boilerplate
//= require_tree ./plugins/

//= require libs/markerclusterer.js
//= require libs/richmarker.js
//= require libs/infobox.js
//= require gmaps/google
//= require libs/gmaps_overrides
//= require ./plugins_initalization

// ---------------------------------- Backbone
//= require libs/backbone
//= require libs/backbone.marionette
//= require libs/backbone-validation
//= require libs/backbone.googlemaps
//= require libs/backbone.paginator.js
//= require libs/backbone.poller.js
//= require libs/Backbone.ModelBinder.js
//= require libs/Backbone.CollectionBinder.js
//= require backbone/cours_avenue

// ---------------------------------- React
//= require react
//= require react_ujs
require('./react/components');

// Default magnificpopup style
// http://codepen.io/dimsemenov/pen/GAIkt
$.magnificPopup.defaults.callbacks = {
    beforeOpen: function() {
       this.st.mainClass = 'mfp-move-horizontal';
    }
}
//delay removal by X to allow out-animation
$.magnificPopup.defaults.removalDelay = 500;

(function($) {
  $.fn.yellowFade = function(options) {
    options = options || {};
    $(this).each(function () {
        var fadeIt;
        options.delay = options.delay || 0;
        var $this = $(this);
        var el    = $this;
        fadeIt = function () {
            $("<div/>")
                .width(el.outerWidth())
                .height(el.outerHeight())
                .css({
                    "position"        : "absolute",
                    "left"            : el.offset().left,
                    "top"             : el.offset().top,
                    "background-color": "#ffff99",
                    "opacity"         : ".7",
                    "z-index"         : "9999999"
                }).appendTo('body').fadeOut(1000).queue(function () { $(this).remove(); });
        }
        _.delay(fadeIt, options.delay);
    });
  }
})(jQuery);
