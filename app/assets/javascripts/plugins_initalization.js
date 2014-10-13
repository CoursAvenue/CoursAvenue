$(function() {
    // Setting default settings of Fancybox
    $.fancybox.defaults.tpl.closeBtn = '<a title="Fermer" class="fancybox-item fancybox-close fa fa-close" href="javascript:;"></a>';
    $.fancybox.defaults.afterShow = function () {
        $.each(GLOBAL.initialize_callbacks, function(i, func) { func(); });
    };
    $.fancybox.defaults.helpers.title = null;

    $('input, textarea').placeholder();
    GLOBAL.initialize_fancy = function($elements) {
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
    GLOBAL.initialize_fancy($('[data-behavior="fancy"]'));
    $('body').on('click', '[data-behavior=modal]', function(event) {
        event.preventDefault();
        var $this        = $(this);
        var width        = $this.data('width') || 'auto';
        var height       = $this.data('height') || 'auto';
        var padding      = (typeof($this.data('padding')) == 'undefined' ? '15' : $this.data('padding'));
        var top_ratio    = (typeof($this.data('top-ratio')) == 'undefined' ? '0.5' : $this.data('top-ratio'));
        var close_click  = (typeof($this.data('close-click')) == 'undefined' ? true : $this.data('close-click'));
        var lock_overlay = (typeof($this.data('lock-overlay')) == 'undefined' ? false : true);
        $.fancybox.open($this, {
                padding     : parseInt(padding),
                topRatio    : parseFloat(top_ratio),
                openSpeed   : 300,
                maxWidth    : 1200,
                maxHeight   : (window.innerHeight - 150),
                fitToView   : false,
                width       : width,
                height      : height,
                autoSize    : false,
                autoResize  : true,
                helpers : {
                    overlay: {
                        locked: true,
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
            if ($(this).data('only-week-day')) {
                var days_of_week = [0,1,2,3,4,5,6];
                days_of_week.splice(days_of_week.indexOf($(this).data('only-week-day')), 1);
                $(this).datepicker('setDaysOfWeekDisabled', days_of_week);
            }

        });
    };
    GLOBAL.initialize_callbacks.push(datepicker_initializer);

    GLOBAL.chosen_initializer = function() {
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
    GLOBAL.initialize_callbacks.push(GLOBAL.chosen_initializer);
    $('body').tooltip({
        selector: '[data-behavior=tooltip],[data-toggle=tooltip]'
    });
    $('body').popover({
        selector: '[data-behavior=popover],[data-toggle=popover]',
        trigger: 'hover'
    });

    // Initialize all callbacks
    GLOBAL.reinitializePlugins = function() {
        $.each(GLOBAL.initialize_callbacks, function(i, func) { func(); });
    };
    GLOBAL.reinitializePlugins();

    $('[data-behavior=sticky]').each(function(index, el) {
        $(this).sticky(this.dataset);
    });

    // $.stellar({ horizontalScrolling: false });
    $.stellar({ horizontalScrolling: false, verticalOffset: -200 });

    $('body').on('click', '[data-behavior=scroll-to]', function(event) {
        if ($(this).data('wrapper')) {
            $($(this).data('wrapper')).scrollTo($(this.hash), { duration: 500, offset: { top: $(this).data('offset-top') || 0 } });
        } else {
            $.scrollTo($(this.hash), { duration: 500, offset: { top: $(this).data('offset-top') || 0 } });
        }
        if (!$(this).data('bubble')) {
            return false;
        }
    });
    if (typeof(mixpanel) != 'undefined') {
        mixpanel.track_links("[data-track-link]", "Clicked tracker", function(el) {
            return {
              text: $(el).text(),
              info: $(el).data('info')
            }
        });
    }
});
