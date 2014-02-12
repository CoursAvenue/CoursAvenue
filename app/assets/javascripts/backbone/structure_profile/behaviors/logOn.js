
// Behaviors.logOn
// -----------------------
//
// **usage**
// ```
// .tab.hidden{ data: { behaviors: ['logActivate', 'logCousesTabClicked'] }}
// ```
//
// **todo**
//
// Once I've implemented matchers, this will be called loggerFor instead of logOn
StructureProfile.module('Behaviors.logOn', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    Module.attachTo = function (options) {
        Module.start();

        var $element    = $(options.element),
            event       = options.event.replace(/([A-Z])/g, ':$1').replace(/^:/, '').toLowerCase(); // from camel to event style

        $element.on(event, console.log);
    };

}, undefined);
