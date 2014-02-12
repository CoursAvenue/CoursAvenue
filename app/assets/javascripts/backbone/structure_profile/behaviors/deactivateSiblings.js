
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
StructureProfile.module('Behaviors.deactivateSiblings', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    Module.attachTo = function (options) {
        Module.start();

        var $element  = $(options.element),
            $siblings = $element.siblings();

        $element.on("activate", function () {
            $siblings.trigger("deactivate");
        });
    };

}, undefined);

