
// Behaviors.deactivateSiblings
// -----------------------
//
// Any time the element becomes active, it triggers 'deactivate' on all of the sibling
// elements. Any sibling element that has implemented some behavior on deactivate will
// do its thing.
//
// **usage**
// ```
// .tab.hidden{ data: { behaviors: 'deactivateSiblings' }}
// ```
Daedalus.module('Behaviors.deactivateSiblings', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    Module.attachTo = function (options, element) {
        Module.start();

        var $element  = $(element),
            $siblings = $element.siblings();

        $element.on("activate", function () {
            $siblings.trigger("deactivate");
        });
    };

    // default matcher
    App.Behaviors.registerMatcher(function activeOnMatcher (data_behavior) {
        var match  = data_behavior.match(/deactivateSiblings/), // slice off the full match
            result = (match === null) ? false : {};

        return result;
    }, Module);

}, undefined);

