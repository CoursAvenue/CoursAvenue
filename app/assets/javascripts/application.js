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
//= require jquery_ujs
//= require libs/jquery-ui-1.10.3.custom

// ---------------------------------- Lib includes
//= require libs/handlebars
//= require libs/handlebars-helpers
//= require libs/chosen.jquery
//= require libs/jquery.tablesorter
//= require libs/jquery.cookie
//= require libs/jquery.cycle.lite
//= require libs/typeahead
//= require libs/jquery.scrollTo
//= require libs/jquery.nouislider
//= require libs/jquery.Jcrop
//= require libs/jquery.fileupload/vendor/jquery.ui.widget
//= require libs/jquery.fileupload/jquery.iframe-transport
//= require libs/jquery.fileupload/jquery.fileupload
//= require libs/jquery.fileupload/jquery.fileupload-process
//= require libs/jquery.fileupload/jquery.fileupload-validate
//= require libs/jquery.fileupload/jquery.fileupload-image
//= require libs/jquery.stickem
//= require libs/jquery.masonry

//= require libs/fancybox/jquery.fancybox
//= require_tree ./libs/fancybox/helpers/

//---- Bootstrap plugins
//= require libs/bootstrap.tooltip
//= require libs/bootstrap.tab
//= require libs/bootstrap.datepicker
//= require libs/locales/bootstrap.datepicker.fr


//---- Highcharts
//= require libs/highcharts/highcharts
//= require libs/highcharts/modules/exporting

//= require zeroclipboard

// ---------------------------------- Mootols Objects
// See boilerplate and pattern:
// - http://jqueryboilerplate.com/
// - https://github.com/jquery-boilerplate/jquery-patterns/
// - https://github.com/jquery-boilerplate/jquery-boilerplate
//= require_tree ./plugins/
// require plugins/address_picker
// require plugins/checkbox_list
// require plugins/city_autocomplete
// require plugins/closer
// require plugins/date_range
// require plugins/drop_down
// require plugins/dropped_options
// require plugins/flash
// require plugins/input_updaters
// require plugins/read_more
// require plugins/text_counter
// require plugins/textarea_resizer
// require plugins/toggler
// require plugins/time_range

//= require_tree ./gmaps4rails/

$(function() {
    var global = GLOBAL.namespace('GLOBAL');
    $("[data-behavior=modal]").each(function() {
        var width  = $(this).data('width') || '70%';
        var height = $(this).data('height') || '70%';
        $(this).fancybox({
                openSpeed   : 300,
                maxWidth    : 800,
                maxHeight   : 500,
                fitToView   : false,
                width       : width,
                height      : 'auto',
                autoSize    : false,
                ajax        : {
                    complete: function(){
                        $.each(global.initialize_callbacks, function(i, func) { func(); });
                    }
                }
        });
    });
    var datepicker_initializer = function() {
        $('[data-behavior=datepicker]').each(function() {
            $(this).datepicker({
                format: 'dd/mm/yyyy',
                weekStart: 1,
                language: 'fr'
            });
            $(this).on('changeDate', function(){
                $(this).datepicker('hide');
            });
        });
    };
    global.initialize_callbacks.push(datepicker_initializer);

    var chosen_initializer = function() {
        // -------------------------- Chosen
        $('[data-behavior=chosen]').each(function() {
            $(this).chosen({
                no_results_text: 'Pas de résultat...'
            });
        });
    };
    global.initialize_callbacks.push(chosen_initializer);
    var copy_initializer = function() {
        $("[data-behavior=copy-to-clipboard]").each(function(index, element) {
            var clip = new ZeroClipboard(element);
            clip.on('mousedown', function(client) {
                GLOBAL.flash('Votre texte à bien été copié');
            });
        });
    };
    global.initialize_callbacks.push(copy_initializer);
    var tooltip_initializer = function() {
        $('[data-behavior=tooltip]').each(function(el) {
            $(this).tooltip();
        });
    };
    global.initialize_callbacks.push(tooltip_initializer);

    // Initialize all callbacks
    $.each(global.initialize_callbacks, function(i, func) { func(); });
});
