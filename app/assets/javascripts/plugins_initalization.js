$(function() {
    var global = GLOBAL.namespace('GLOBAL');
    $("[data-behavior=modal]").each(function() {
        var width  = $(this).data('width') || 'auto';
        var height = $(this).data('height') || 'auto';
        $(this).fancybox({
                openSpeed   : 300,
                maxWidth    : 800,
                maxHeight   : 500,
                fitToView   : false,
                width       : width,
                height      : height,
                autoSize    : false,
                autoResize  : true,
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
                format: GLOBAL.DATE_FORMAT,
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
                no_results_text: 'Pas de résultat...',
                search_contains: true
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
