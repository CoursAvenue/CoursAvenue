$(function() {
    // Setting default settings of Fancybox
    $.fancybox.defaults.tpl.closeBtn = '<a title="Fermer" class="fancybox-item fancybox-close fa fa-close" href="javascript:;"></a>';
    $.fancybox.defaults.afterShow = function () {
        $.each(global.initialize_callbacks, function(i, func) { func(); });
    };
    $.fancybox.defaults.helpers.title = null;

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
    $('body').on('click', '[data-behavior=modal]', function(event) {
        event.preventDefault();
        var $this       = $(this);
        var width       = $this.data('width') || 'auto';
        var height      = $this.data('height') || 'auto';
        var padding     = (typeof($this.data('padding')) == 'undefined' ? '15' : $this.data('padding'));
        var top_ratio  = (typeof($this.data('top-ratio')) == 'undefined' ? '0.5' : $this.data('top-ratio'));
        var close_click =  (typeof($this.data('close-click')) == 'undefined' ? true : $this.data('close-click'));
        $.fancybox.open($this, {
                padding     : parseInt(padding),
                topRatio    : parseFloat(top_ratio),
                openSpeed   : 300,
                maxWidth    : 1200,
                maxHeight   : 1200,
                fitToView   : false,
                width       : width,
                height      : height,
                autoSize    : false,
                autoResize  : true,
                helpers : {
                    overlay: {
                        locked: false,
                        closeClick: close_click
                    }
                }
        });
        return false;
    });
    var datepicker_initializer = function() {
        $('[data-behavior=datepicker]').each(function() {
            var datepicker_options = {
                format: GLOBAL.DATE_FORMAT,
                weekStart: 1,
                language: 'fr',
                autoclose: true,
                todayHighlight: true
            };
            if ($(this).data('start-date')) {
                datepicker_options.startDate = $(this).data('start-date');
            }
            $(this).datepicker(datepicker_options);
        });
    };
    global.initialize_callbacks.push(datepicker_initializer);

    global.chosen_initializer = function() {
        // -------------------------- Chosen
        $('[data-behavior=chosen]').each(function() {
            $(this).chosen({
                no_results_text          : 'Pas de résultat...',
                placeholder_multiple_text: 'Selectionnez une ou plusieurs options',
                placeholder_single_text  : 'Selectionnez une option',
                search_contains          : true,
                width                    : $(this).css('width'), // Returns undefined if there is no width style defined.
                inherit_select_classes   : true
            });
        });
    };
    global.initialize_callbacks.push(global.chosen_initializer);
    $('body').tooltip({
        selector: '[data-behavior=tooltip],[data-toggle=tooltip]'
    });
    var popover_initializer = function() {
        $('[data-toggle=popover]').popover();
    };
    global.initialize_callbacks.push(popover_initializer);

    // Initialize all callbacks
    global.reinitializePlugins = function() {
        $.each(global.initialize_callbacks, function(i, func) { func(); });
    };
    global.reinitializePlugins();

    $('[data-behavior=sticky]').each(function(index, el) {
        $(this).sticky(this.dataset);
    });
    $('[data-behavior=parallax]').stellar();

    $('body').on('click', '[data-behavior=scroll-to]', function(event) {
        $.scrollTo($(this.hash), { duration: 500, offset: { top: $(this).data('offset-top') || 0 } });
        return false;
    });
});
