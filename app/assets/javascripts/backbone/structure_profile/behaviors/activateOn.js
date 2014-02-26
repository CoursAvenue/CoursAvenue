
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
Daedalus.module('Behaviors.activateOn', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    var _activate = function activate (element, e) {
        $(element).addClass("active");
        $(element).trigger("activate");
    };

    // TODO when we have underscore 1.6.0 we will be able to flip the order
    // of these parameters.
    Module.attachTo = function attachTo (options, element) {
        Module.start();

        var $element    = $(element),
            activate    = _.partial(_activate, element),
            event       = options.event.replace(/([A-Z])/g, ':$1').replace(/^:/, '').toLowerCase(); // from camel to event style

        $(document).on(event, activate);

        $element.on("deactivate", function removeActiveClass (e) {
            $element.removeClass("active");
        });
    };

    // activateOn matches data-behaviors like "activateOnSomeCamelizedEventName"
    App.Behaviors.registerMatcher(function activeOnMatcher (data_behavior) {
        var match  = data_behavior.match(/activateOn(.*)/), // slice off the full match
            result = false;

        if (match !== null) {
            match = match.slice(1); // cut off the complete match

            result = {
                event: match[0]
            }
        }

        return result;
    }, Module);

}, undefined);

