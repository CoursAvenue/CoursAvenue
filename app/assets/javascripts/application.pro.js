//= require libs/underscore
//= require global

// ---------------------------------- Core include
//= require libs/jquery
//= require jquery_ujs
//= require libs/jquery-ui-1.10.3.custom
//= require js-routes

// ---------------------------------- Lib includes
//= require libs/handlebars
//= require libs/handlebars-helpers
//= require libs/chosen.jquery
//= require libs/jquery.tablesorter
//= require libs/jquery.cookie
//= require libs/typeahead
//= require libs/jquery.scrollTo
//= require libs/jquery.Jcrop
//= require libs/jquery.fileupload/vendor/jquery.ui.widget
//= require libs/jquery.fileupload/jquery.iframe-transport
//= require libs/jquery.fileupload/jquery.fileupload
//= require libs/jquery.fileupload/jquery.fileupload-process
//= require libs/jquery.fileupload/jquery.fileupload-validate
//= require libs/jquery.fileupload/jquery.fileupload-image
//= require libs/jquery.nouislider
//= require libs/jquery.lazyload
//= require libs/responsiveslides
//= require libs/jquery.placeholder
//= require libs/stellar

//= require libs/jquery.magnific-popup
//= require libs/fancybox/jquery.fancybox

//= require libs/fingerprint

//= require libs/countdown

//= require_tree ./libs/fancybox/helpers/

//---- Bootstrap plugins
//= require libs/bootstrap/bootstrap.transition
//= require libs/bootstrap/bootstrap.collapse
//= require libs/bootstrap/bootstrap.tooltip
//= require libs/bootstrap/bootstrap.popover
//= require libs/bootstrap/bootstrap.tab
//= require libs/bootstrap/bootstrap.datepicker
//= require libs/bootstrap/bootstrap.button
//= require libs/bootstrap/datepicker-locales/bootstrap.datepicker.fr


//---- Highcharts
//= require libs/highcharts/highcharts
//= require libs/highcharts/modules/exporting

// ---------------------------------- jQuery plugins
// See boilerplate and pattern:
// - http://jqueryboilerplate.com/
// - https://github.com/jquery-boilerplate/jquery-patterns/
// - https://github.com/jquery-boilerplate/jquery-boilerplate
//= require_tree ./plugins/

//= require libs/markerclusterer
//= require gmaps/google

//= require libs/filepicker

//= require ./plugins_initalization

// ---------------------------------- Backbone
//= require libs/backbone
//= require backbone.marionette
//= require libs/backbone.googlemaps
//= require backbone-relational
//= require libs/backbone.paginator.js
//= require libs/backbone.poller.js
//= require backbone/cours_avenue.pro

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
