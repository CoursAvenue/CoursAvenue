
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
Daedalus.module('Behaviors.logOn', function(Module, App, Backbone, Marionette, $, _, undefined) {
    this.startWithParent = false;

    Module.attachTo = function (options, element) {
        Module.start();

        var $element    = $(element),
            event       = options.event.replace(/([A-Z])/g, ':$1').replace(/^:/, '').toLowerCase(); // from camel to event style

        $element.on(event, console.log);
    };

    // activateOn matches data-behaviors like "activateOnSomeCamelizedEventName"
    App.Behaviors.registerMatcher(function activeOnMatcher (data_behavior) {
        var match  = data_behavior.match(/loggerFor(.*)/), // slice off the full match
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
