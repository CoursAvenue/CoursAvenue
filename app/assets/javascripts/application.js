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
//= require mootools
//= require mootools-more
//= require mootools_ujs
//= require_tree ./objects/
//= require_tree ./gmaps4rails/
//= require libs/datepicker/Locale.fr-FR.DatePicker
//= require libs/datepicker/Picker
//= require libs/datepicker/Picker.Attach
//= require libs/datepicker/Picker.Date
//= require libs/datepicker/Picker.Date.Range

window.addEvent('domready', function() {
    Locale.use('fr-FR');
    new Picker.Date($$('[data-behavior=datepicker]'),
    {
        pickerClass: 'datepicker_dashboard',
        months_abbr: Locale.get('Date.months'),
        days_title: function(date, options){
            return date.format('%B %Y');
        }
    });

    new Picker.Date($$('[data-behavior=timepicker]'), {
        pickOnly: 'time',
        timeWheelStep: 5,
        pickerClass: 'datepicker_dashboard'
    });

    var scroll = new Fx.Scroll($(document.body), {
        wait: false,
        duration: 250,
        transition: Fx.Transitions.Quad.easeInOut
    });
    Gmaps.map.callback = function() {
        for (var i = 0; i <  this.markers.length; ++i) {
            google.maps.event.addListener(Gmaps.map.markers[i].serviceObject, 'click', function() {
                var course_element = $$('.course-element[data-structure_id=' + this.id + ']')[0];
                scroll.toElement(course_element);
                $$('.course-element').removeClass('selected');
                course_element.addClass('selected');
            }.bind(Gmaps.map.markers[i]));
        }
    };

});
