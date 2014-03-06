// Behaviors.sticky
// -----------------------
//
// This behavior attaches the jQuery sticky plugin to the given element.
//
// **usage**
// ```
// .tab.hidden{ data: { behaviors: 'sticky' }}
// ```
Daedalus.module('Behaviors.sticky', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    var _activate = function activate (element, e) {
        $(element).addClass("active");
        $(element).trigger("activate");
    };

    // TODO when we have underscore 1.6.0 we will be able to flip the order
    // of these parameters.
    Module.attachTo = function attachTo (options, element) {
        Module.start();

        $(element).sticky({ z: 10, old_width: false });
    };

    // activateOn matches data-behaviors like "activateOnSomeCamelizedEventName"
    App.Behaviors.registerMatcher(function activeOnMatcher (data_behavior) {
        var match  = data_behavior.match(/sticky/), // slice off the full match
            result = false;

        if (match !== null) {

            result = { }
        }

        return result;
    }, Module);

}, undefined);

