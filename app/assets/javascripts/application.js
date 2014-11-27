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
//= require libs/jquery.cookie
//= require libs/typeahead
//= require libs/jquery.scrollTo
//= require libs/jquery.nouislider
//= require libs/jquery.lazyload
//= require libs/responsiveslides
//= require libs/jquery.placeholder

//= require libs/jquery.magnific-popup
//= require libs/fancybox/jquery.fancybox

//= require libs/fingerprint

//= require_tree ./libs/fancybox/helpers/

//---- Bootstrap plugins
//= require libs/bootstrap/bootstrap.transition
//= require libs/bootstrap/bootstrap.collapse
//= require libs/bootstrap/bootstrap.tooltip
//= require libs/bootstrap/bootstrap.popover
//= require libs/bootstrap/bootstrap.tab
//= require libs/bootstrap/bootstrap.datepicker
//= require libs/bootstrap/bootstrap.button
//= require libs/bootstrap/bootstrap.scrollspy
//= require libs/bootstrap/datepicker-locales/bootstrap.datepicker.fr
//= require libs/moment
//= require libs/retina

// ---------------------------------- jQuery plugins
// See boilerplate and pattern:
// - http://jqueryboilerplate.com/
// - https://github.com/jquery-boilerplate/jquery-patterns/
// - https://github.com/jquery-boilerplate/jquery-boilerplate
//= require_tree ./plugins/

//= require gmaps/google

//= require ./plugins_initalization

// ---------------------------------- Backbone
//= require libs/backbone
//= require libs/backbone-validation
//= require backbone.marionette
//= require libs/backbone.googlemaps
//= require backbone-relational
//= require libs/backbone.paginator.js
//= require libs/backbone.poller.js
//= require backbone/cours_avenue

// Default magnificpopup style
// http://codepen.io/dimsemenov/pen/GAIkt
$.magnificPopup.defaults.callbacks = {
    beforeOpen: function() {
       this.st.mainClass = 'mfp-move-horizontal';
    }
}
//delay removal by X to allow out-animation
$.magnificPopup.defaults.removalDelay = 500;

