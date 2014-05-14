$(function() {
    $('input, textarea').placeholder();
    var global = GLOBAL.namespace('GLOBAL');
    global.initialize_fancy = function($elements) {
        // Warning !
        // Do not iterate over each elements beccause it will break thumbs
        var width      = $elements.first().data('width') || 800;
        var height     = $elements.first().data('height') || 600;
        $elements.fancybox({ padding  : 0,
                             width   : width,
                             height  : height,
                             helpers : {
                                 media : {},
                                 thumbs : {
                                     width  : 75,
                                     height : 50
                                 },
                                overlay: {
                                  locked: false
                                }
                            }
                         });
    };
    global.initialize_fancy($('[data-behavior="fancy"]'));
    global.modal_initializer = function modal_initializer () {
        $("[data-behavior=modal]").each(function() {
            var $this       = $(this);
            var width       = $this.data('width') || 'auto';
            var height      = $this.data('height') || 'auto';
            var padding     = (typeof($this.data('padding')) == 'undefined' ? '15' : $this.data('padding'));
            var close_click =  (typeof($this.data('close-click')) == 'undefined' ? true : $this.data('close-click'));
            $(this).fancybox({
                    padding     : parseInt(padding),
                    openSpeed   : 300,
                    maxWidth    : 1200,
                    maxHeight   : 1200,
                    fitToView   : false,
                    width       : width,
                    height      : height,
                    autoSize    : false,
                    autoResize  : true,
                    ajax        : {
                        complete: function(){
                            $.each(global.initialize_callbacks, function(i, func) { func(); });
                        }
                    },
                    tpl: {
                        closeBtn : '<a title="Fermer" class="fancybox-item fancybox-close fa fa-times" href="javascript:;"></a>',
                    },
                    helpers : {
                        title : {
                            type: 'outside',
                            position : 'top'
                        },
                        overlay: {
                            locked: false,
                            closeClick: close_click
                        }
                    }
            });
        });
    }
    global.modal_initializer();
    global.initialize_callbacks.push(global.modal_initializer);
    var datepicker_initializer = function() {
        $('[data-behavior=datepicker]').each(function() {
            $(this).datepicker({
                format: GLOBAL.DATE_FORMAT,
                weekStart: 1,
                language: 'fr',
                autoClose: true,
                todayHighlight: true
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
                search_contains: true,
                width: $(this).css('width'), // Returns undefined if there is no width style defined.
                inherit_select_classes: true
            });
        });
    };
    global.initialize_callbacks.push(chosen_initializer);
    var tooltip_initializer = function() {
        $('[data-behavior=tooltip]').tooltip();
    };
    global.initialize_callbacks.push(tooltip_initializer);

    var popover_initializer = function() {
        $('[data-toggle=popover]').popover();
    };
    global.initialize_callbacks.push(popover_initializer);

    // Initialize all callbacks
    GLOBAL.reinitializePlugins = function() {
        $.each(global.initialize_callbacks, function(i, func) { func(); });
    };
    GLOBAL.reinitializePlugins();
});
