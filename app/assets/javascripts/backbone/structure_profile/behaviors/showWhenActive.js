
// Behaviors.showWhenActive
// -----------------------
//
// Any time this element becomes active, it is shown. It is hidden when
// it is deactivate, and by default we expect it to be hidden, but this
// is not enforced. This behavior is agnostic
// as to how the element became active, and needs to be either combined with
// `activateOn`, or used together with a view that will activate the element.
//
// **usage**
// ```
// .tab.hidden{ data: { behaviors: 'showWhenActive' }}
// ```
Daedalus.module('Behaviors.showWhenActive', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    Module.attachTo = function (options, element) {
        Module.start();

        var $element = $(element);

        $element.on("activate", function showTabContents (e) {
            $(this).show();
        });

        $element.on("deactivate", function hideTabContents (e) {
            $(this).hide();
        });
    };

    // default matcher
    App.Behaviors.registerMatcher(function activeOnMatcher (data_behavior) {
        var match  = data_behavior.match(/showWhenActive/), // slice off the full match
            result = (match === null) ? false : {};

        return result;
    }, Module);

}, undefined);

