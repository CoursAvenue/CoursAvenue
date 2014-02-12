
// Behaviors.activateOn
// -----------------------
//
// This behavior defines a global event that will cause this element to emit the "activate"
// event. The behavior name must be followed by the camelized signature of the event that
// will cause this element to activate. For example, attaching the behavior `activateOnCoursesTabClicked`
// will cause this element to activate when `courses:tab:clicked` is triggered somewhere
// in the DOM.
//
// **usage**
// ```
// .tab.hidden{ data: { behaviors: ['activateOnMapMarkerClicked', 'activateOnCoursesTabClicked'] }}
// ```
StructureProfile.module('Behaviors.activateOn', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    var _activate = function activate (element, e) {
        var $element = $(element);
        $element.trigger("activate");
    };

    Module.attachTo = function (options) {
        Module.start();

        var $element    = $(options.element),
            activate    = _.partial(_activate, options.element),
            event       = options.event.replace(/([A-Z])/g, ':$1').replace(/^:/, '').toLowerCase(); // from camel to event style

        $(document).on(event, activate);
    };

}, undefined);

