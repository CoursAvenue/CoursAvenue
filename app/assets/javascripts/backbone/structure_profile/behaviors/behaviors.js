
// Behaviours
// ----------
//
// The Behaviors module is a collection of functions that each take an element and attach
// some event handlers to it, or to the document. Each behavior is meant to be stateless,
// general, and as simple as possible. By combining behaviors on an object, we can easily
// create more complicated DOM interactions, without the need to instantiate a full-fledged
// Marionette view.
//
// **data API**
//
// _behaviors_: a name of a behavior the element is to implement, or an array of such names.
//
// **submodules**
//
// [WIP] Submodules that implement a match function will be passed the given behavior name,
// and the first one that matches will be attached to the element. At the moment the matching
// is all done here.
//
// **usage**
//
// ```
// .tab.hidden{ data: { behaviors: ['showWhenActive', 'activateOnCoursesTabClicked', 'deactivateSiblings'] }}
// ```
StructureProfile.module('Behaviors', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.addInitializer(function () {
        $("[data-behaviors]").each(function (index, element) {
            var $element  = $(element),
                behaviors = $element.data("behaviors");

            if (!_.isArray(behaviors)) {
                behaviors = [behaviors];
            }

            _.each(behaviors, function (behavior_name) {
                var behavior = behavior_name;

                if (Module[behavior] != undefined) {
                    Module[behavior].attachTo({ element: element, event: event });
                } else {
                    var match = behavior.match(/(.*?On)(.*)/).slice(1); // slice off the full match
                    var event = match[1];
                    behavior  = match[0];

                    if (Module[behavior] != undefined) {
                        Module[behavior].attachTo({ element: element, event: event });
                    } else if (behavior.match("emit")) {
                        match = behavior.match(/(emit)(.*)On/).slice(1);
                        var app_event = match[1];
                        behavior      = match[0];

                        Module[behavior].attachTo({ element: element, app_event: app_event, dom_event: event });
                    }
                }
            });
        });
    });

}, undefined);

