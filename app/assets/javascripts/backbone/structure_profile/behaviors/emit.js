
// Behaviors.emit
// -----------------------
//
// This behavior allows the given element to translate a particular DOM event
// into an application event. This translation is commonly implemented by
// views using the events hash, but a view whose sole purpose is to forward
// events can now be replaced by a component or some behaviors.
//
// **usage**
// ```
// .tab.hidden{ data: { behaviors: ['emitCoursesTabClickedOnClick'] }}
// ```
StructureProfile.module('Behaviors.emit', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    var _broadcast = function broadcast (event, e) {
        $(this).trigger(event, e);
    };

    Module.attachTo = function attachTo (options, element) {
        Module.start();

        var $element    = $(element),
            app_event   = options.app_event.replace(/([A-Z])/g, ':$1').replace(/^:/, '').toLowerCase(),
            dom_event   = options.dom_event.replace(/([A-Z])/g, ':$1').replace(/^:/, '').toLowerCase(),
            broadcast   = _.partial(_broadcast, app_event);

        $element.on(dom_event, broadcast);
    };

    // emit matches data-behaviors like "emitSomeAppEventOnSomeDomEvent"
    App.Behaviors.registerMatcher(function activeOnMatcher (data_behavior) {
        var match  = data_behavior.match(/emit(.*)On(.*)/), // slice off the full match
            result = false;

        if (match !== null) {
            match = match.slice(1); // cut off the complete match

            result = {
                app_event: match[0],
                dom_event: match[1]
            }
        }

        return result;
    }, Module);

}, undefined);

