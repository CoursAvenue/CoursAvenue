/* EventTemplate
 * -------------
 *
 * An event template listens to an event and provides the data the event
 * contained to a template.
 *
 * **Usage**:
 *
 * ```html.haml
 * %div{ data: { view: 'EventTemplate', for: 'CoursesAnnounce' }}
 * ```
 *
 *  */
Daedalus.module('Views.EventTemplate', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    Module.EventTemplate = Marionette.ItemView.extend({

        update: function update (data) {
            debugger

        },

        serializaData: function serializaData () {
            return {};
        }
    });

    // a function to run when it is determined that this module will be used. Creates
    // a TabManager view object for each element with data-view=TabManager.
    Module.addInitializer(function () {
        $("[data-view=" + Module.moduleName + "]").each(function (index, element) {

            var view         = buildView(element, $(element).data()),
                region_name  = Module.moduleName + _.capitalize(view.cid),
                $element     = $(element),
                regions      = {};

            regions[region_name] = "#" + view.cid;
            $element.attr("id", view.cid);

            App.addRegions(regions);
            App[region_name].show(view);

            consumeData($element);

            /* view registers to be notified of events on layout */
            Marionette.bindEntityEvents(view, App.Views, { });
            App.Views.listenTo(view, 'all', App.Views.broadcast);
        });
    });

    var consumeData = function consumeData ($element) {
        $element.removeAttr("data-template");
        $element.removeAttr("data-view");
        $element.removeAttr("data-for");
    };

    /* ***
     * ### \#buildView
     *
     * The EventTemplate attaches itself to its parent node, and uses the element as
     * its tagName and className.
     *
     * */
    var buildView = function buildView (element, options) {
        var $element          = $(element),
            view              = options.view,
            event             = options.for,
            template          = options.template,
            tagName           = $element[0].nodeName.toLowerCase(),
            className         = $element[0].className,
            options = {};

        template = template.replace(/([A-Z])/g, '_$1').replace(/^_/, '').toLowerCase();
        event    = ':' + event.replace(/([A-Z])/g, ':$1').replace(/^:/, '').toLowerCase(); // from camel to event style

        options.template            = 'backbone/structure_profile/views/event_templates/templates/' + template;
        options.events = {
            event: 'update'
        };

        return new Module.EventTemplate(options);
    };

}, undefined);
