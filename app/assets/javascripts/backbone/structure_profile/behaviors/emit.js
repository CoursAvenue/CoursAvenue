
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

    Module.attachTo = function attachTo (options) {
        Module.start();

        var $element    = $(options.element),
            app_event   = options.app_event.replace(/([A-Z])/g, ':$1').replace(/^:/, '').toLowerCase(),
            dom_event   = options.dom_event.replace(/([A-Z])/g, ':$1').replace(/^:/, '').toLowerCase(),
            broadcast   = _.partial(_broadcast, app_event);

        $element.on(dom_event, broadcast);
    };

}, undefined);

