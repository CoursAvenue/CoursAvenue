$(function() {
    // Setting default settings of Fancybox
    $.fancybox.defaults.tpl.closeBtn = '<a title="Fermer" class="fancybox-item fancybox-close fa-times fixed north east push fa-2x" href="javascript:;"></a>';
    $.fancybox.defaults.maxHeight = window.innerHeight - 150;
    $.fancybox.defaults.afterShow = function () {
        $.each(COURSAVENUE.initialize_callbacks, function(i, func) { func(); });
    };
    $.fancybox.defaults.helpers.title = null;

    $('input, textarea').placeholder();
    COURSAVENUE.initialize_fancy = function($elements) {
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
                                     width  : 135,
                                     height : 90
                                 },
                                overlay: {
                                  locked: false
                                }
                            }
                         });
    };
    COURSAVENUE.initialize_fancy($('[data-behavior="fancy"]'));
    $('body').on('click', '[data-behavior=modal]', function(event) {
        event.preventDefault();
        var $this              = $(this);
        var width              = $this.data('width') || 'auto';
        var height             = $this.data('height') || 'auto';
        var padding            = (typeof($this.data('padding')) == 'undefined' ? '15' : $this.data('padding'));
        var top_ratio          = (typeof($this.data('top-ratio')) == 'undefined' ? '0.5' : $this.data('top-ratio'));
        var close_click        = (typeof($this.data('close-click')) == 'undefined' ? true : $this.data('close-click'));
        var lock_overlay       = (typeof($this.data('lock-overlay')) == 'undefined' ? false : true);
        var after_close_reload = (typeof($this.data('after-close-reload')) == 'undefined' ? null : function () { location.reload(); return ; });
        $.fancybox.open($this, {
                padding     : parseInt(padding),
                topRatio    : parseFloat(top_ratio),
                openSpeed   : 300,
                maxWidth    : 1200,
                fitToView   : false,
                width       : width,
                height      : height,
                autoSize    : false,
                autoResize  : true,
                afterClose  : _.after($.fancybox.defaults.afterClose, after_close_reload),
                helpers : {
                    overlay: {
                        locked: false,
                        closeClick: close_click
                    }
                }
        });
        return false;
    });

    // Remove rows that contains only old or new days
    COURSAVENUE.datepicker_function_that_hides_inactive_rows = function() {
        _.each($('.datepicker tr'), function(tr) {
            $tr = $(tr);
            if ($tr.find('.old').length == 7 || $tr.find('.new').length == 7) {
                $tr.remove();
            }
        });
    };
    COURSAVENUE.datepicker_initializer = function() {
        $('[data-behavior=datepicker]').each(function() {
            var datepicker_options = {
                format: COURSAVENUE.constants.DATE_FORMAT,
                weekStart: 1,
                language: 'fr',
                autoclose: true,
                todayHighlight: true
            };
            if ($(this).data('clear-btn')) {
                datepicker_options.clearBtn = true;
            }
            if ($(this).data('start-date')) {
                datepicker_options.startDate = $(this).data('start-date');
            }
            $(this).datepicker(datepicker_options);
            $(this).datepicker().on('show', COURSAVENUE.datepicker_function_that_hides_inactive_rows);

            if ($(this).data('only-week-day')) {
                var days_of_week = [0,1,2,3,4,5,6];
                days_of_week.splice(days_of_week.indexOf($(this).data('only-week-day')), 1);
                $(this).datepicker('setDaysOfWeekDisabled', days_of_week);
            }
        });
    };
    COURSAVENUE.initialize_callbacks.push(COURSAVENUE.datepicker_initializer);

    COURSAVENUE.chosen_initializer = function() {
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
    COURSAVENUE.initialize_callbacks.push(COURSAVENUE.chosen_initializer);
    $('body').tooltip({
        selector: '[data-behavior=tooltip],[data-toggle=tooltip]'
    });
    $('body').popover({
        selector: '[data-behavior=popover],[data-toggle=popover]',
        trigger: 'hover'
    });
    $('body').on('click', '[data-toggle=tab]', function() {
        $(this).find('input').prop('checked', true);
    })

    // Initialize all callbacks
    COURSAVENUE.reinitializePlugins = function() {
        $.each(COURSAVENUE.initialize_callbacks, function(i, func) { func(); });
    };
    COURSAVENUE.reinitializePlugins();

    $('[data-behavior=sticky]').each(function(index, el) {
        $(this).sticky(this.dataset);
    });

    $('body').on('click', '[data-behavior=scroll-to]', function(event) {
        var duration = $(this).data('duration') || 500;
        if ($(this).data('wrapper')) {
            $($(this).data('wrapper')).scrollTo($(this.hash), { easing: 'easeOutCubic', duration: duration, offset: { top: $(this).data('offset-top') || 0 } });
        } else {
            $.scrollTo($(this.hash || this.dataset.el), { easing: 'easeOutCubic', duration: duration, offset: { top: $(this).data('offset-top') || 0 } });
        }
        if (!$(this).data('bubble')) {
            return false;
        }
    });
    $('[data-behavior="lazy-load"]').lazyload({effect: 'fadeIn'});

    if ($('[data-behavior=parallax]').length > 0) {
        $(window).scroll(function () {
            $('[data-behavior=parallax]').each(function(index, el) {
                var $this = $(this);
                var scrollAmount = ($(window).scrollTop() - $this.offset().top) / 5;
                scrollAmount     = Math.round(scrollAmount);
                $this.css('backgroundPosition', '50% ' + scrollAmount + 'px');
            });
        });
    }
    if ($('[data-behavior=block-parallax]').length > 0) {
        $(window).scroll(function () {
            $('[data-behavior=block-parallax]').each(function(index, el) {
                var $this = $(this);
                var scrollAmount = $(window).scrollTop() / 4;
                scrollAmount     = Math.round(scrollAmount);
                $this.css('marginTop', scrollAmount + 'px');
                $this.css('opacity', 1 - ($(window).scrollTop() / window.screen.height));
            });
        });
    }
    $('.blog-article__content img[title], .blog-article__content img[alt]').each(function() {
        $this = $(this);
        $this.parent().addClass('relative blog-article__image-with-legend');
        $this.addClass('shadowed--bottom');
        var text = $this.attr('title') || $this.attr('alt')
        if (text && text.length > 0) {
            var div = $('<div>').text(text)
                                .addClass('absolute blog-article__legend one-whole soft--sides soft-half--ends bg-black-faded white south west transition-all-500');
        }
        $this.after(div);
    });
    // Responsive menu
    var showSideMenu = function showSideMenu () {
        $('body').toggleClass('side-menu-opened');
    }
    if (COURSAVENUE.helperMethods.isTouchDevice()) {
        $('[data-behavior=toggle-responsive-menu]').on('touchstart', showSideMenu);
    } else {
        $('[data-behavior=toggle-responsive-menu]').click(showSideMenu);
    }

    $('body').on('click', '[data-logger]', function(event) {
        CoursAvenue.statistic.logStat($(this).data('structure-id'), $(this).data('logger'));
    });
});
