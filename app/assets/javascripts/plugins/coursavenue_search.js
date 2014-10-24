/*
    Usage:
    <form  data-behavior='coursavenue-search' />
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "subjectsStructuresPicker",
        defaults = {
          subjects_header_template: '<div class="text--center very-soft bordered--bottom"><strong>Disciplines</strong></div>',
          subjects_template:  "<div>{{ name }}</div>",
          structure_header_template: '<div class="text--center very-soft bordered--bottom"><strong>Professeurs, associations et écoles</strong></div>',
          structure_template: '<a class="flexbox" href="{{ url }}"><div class="flexbox__item text--left" style="width: 40px"><img class="rounded--circle" src="{{logo_url}}" height="30" width="30"></div><div class="flexbox__item">{{name}}</div></a>'
        };

    // The actual plugin constructor
    function Plugin( element, options ) {
        this.element  = element;
        this.$element = $(element);

        // jQuery has an extend method that merges the
        // contents of two or more objects, storing the
        // result in the first object. The first object
        // is generally empty because we don't want to alter
        // the default options for future instances of the plugin
        this.options = $.extend( {}, defaults, options) ;

        this._defaults = defaults;
        this._name = pluginName;

        this.init();
    }

    Plugin.prototype = {

        init: function init () {
            var structure_template, subjects_template, structure_header_template, subjects_header_template;
            // Check if the element has already been initialized before doing the stuff
            this.subjects_input = this.$element.find('[data-type=subjects]');
            this.address_input  = this.$element.find('[data-type=address]');
            this.city_input     = this.$element.find('[name=city]')
            if (this.address_input.length > 0) { this.address_input.addressPicker(); }
            if (this.$element.hasClass('tt-hint')) { return; }
            this.initializeEngines();
            this.initializeTemplates();
            this.subjects_input.typeahead({
                highlight : true,
                minLength: 1,
                autoselect: true
            }, {
                displayKey: 'name',
                templates: {
                    header: this.subjects_header_template,
                    suggestion: this.subjects_template
                },
                source: this.subject_engine.ttAdapter()
            }, {
                displayKey: 'name',
                templates: {
                    header: this.structure_header_template,
                    suggestion: this.structure_template
                },
                source: this.structure_engine.ttAdapter()
            });

            this.$element.submit(function(event, data) {
                var new_action;
                var city = this.city_input.val() || $.cookie('city') || 'paris';
                city = city.replace(/[^A-Za-z]/g, '-').toLowerCase();
                if (this.selected_subject && this.selected_subject.depth == 0) {
                    new_action = Routes.root_search_page_path(this.selected_subject.slug, city);
                    this.subjects_input.removeAttr('name'); // Remove name attribute to prevent word ending in the keywords filter
                } else if (this.selected_subject) {
                    new_action = Routes.search_page_path(this.selected_subject.root, this.selected_subject.slug, city);
                    this.subjects_input.removeAttr('name'); // Remove name attribute to prevent word ending in the keywords filter
                } else {
                    this.subjects_input.attr('name', 'name');
                    new_action = Routes.root_search_page_without_subject_path(city);
                }
                this.$element.attr('action', new_action)

            }.bind(this));

            this.subjects_input.on('typeahead:selected', function(event, data) {
                if (data.type == 'structure') {
                    window.location.href = data.url;
                } else {
                    this.selected_subject = data;
                }
                // Automatically submit form if there is just the subject input
                if (this.address_input.length == 0) {
                    this.$element.submit();
                }
            }.bind(this));
            if (this.address_input.length == 0) {
                this.subjects_input.keydown(function(event) {
                    if(event.keyCode == 13) {
                        this.$element.submit();
                    }
                }.bind(this));
            }
        },

        /*
         * Create Bloodhound engines
         */
        initializeEngines: function initializeEngines () {
            this.subject_engine   = new Bloodhound({
                datumTokenizer: function datumTokenizer (d) { return Bloodhound.tokenizers.whitespace(d.num); },
                queryTokenizer: Bloodhound.tokenizers.whitespace,
                remote: {
                    replace: function replace (url, query ) {
                        query = query.replace(GLOBAL.EXCLUDED_SEARCH_WORDS, '');
                        return Routes.search_subjects_path({format: 'json', name: query});
                    },
                    url: Routes.search_subjects_path({format: 'json', name: '%QUERY'})
                }
            });
            this.structure_engine   = new Bloodhound({
                datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.num); },
                queryTokenizer: Bloodhound.tokenizers.whitespace,
                remote: Routes.search_structures_path({format: 'json'}) + '?name=%QUERY'
            });
            this.subject_engine.initialize();
            this.structure_engine.initialize();
        },

        /*
         * Initialize templates
         */
        initializeTemplates: function initializeTemplates () {
            this.structure_template        = Handlebars.compile(this.options.structure_template);
            this.subjects_template         = Handlebars.compile(this.options.subjects_template);
            this.structure_header_template = Handlebars.compile(this.options.structure_header_template);
            this.subjects_header_template  = Handlebars.compile(this.options.subjects_header_template);
        }
    };

    // A really lightweight plugin wrapper around the constructor,
    // preventing against multiple instantiations
    $.fn[pluginName] = function ( options ) {
        return this.each(function () {
            if (!$.data(this, "plugin_" + pluginName)) {
                $.data(this, "plugin_" + pluginName,
                new Plugin( this, options ));
            }
        });
    }

})( jQuery, window, document );

$(function() {
    var subjects_structures_picker_initializer = function() {
        $('[data-behavior=coursavenue-search]').subjectsStructuresPicker();
    };
    GLOBAL.initialize_callbacks.push(subjects_structures_picker_initializer);
});
