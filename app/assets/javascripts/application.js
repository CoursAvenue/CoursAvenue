// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require global

// ---------------------------------- Core include
//= require mootools
//= require mootools-more
//= require mootools_ujs

// ---------------------------------- Lib includes
//= require libs/handlebars
//= require libs/datepicker/Locale.fr-FR.DatePicker
//= require libs/datepicker/Picker
//= require libs/datepicker/Picker.Attach
//= require libs/datepicker/Picker.Date
//= require libs/datepicker/Picker.Date.Range

// ---------------------------------- Mootols Objects
//= require_tree ./objects/
//= require_tree ./gmaps4rails/

window.addEvent('domready', function() {
    var global = GLOBAL.namespace('GLOBAL');
    Locale.use('fr-FR');
    new Picker.Date($$('[data-behavior=datepicker]'),
        {
        pickerClass: 'datepicker_bootstrap',
        months_abbr: Locale.get('Date.months'),
        days_title: function(date, options){
            return date.format('%B %Y');
        }
    });
    global.Scroller = new Fx.Scroll($(document.body), {
        wait: false,
        duration: 500,
        transition: Fx.Transitions.Quad.easeInOut
    });
});
