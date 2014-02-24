// Views
// -----
//
// The Views module detects the presence of the data-views attribute and
// starts submodules for the given views. In addition, the Views module
// augments the existing Marionette views with additional functionality
// specific to this system.
//
// **data API**
//
// _view_: a name of a behavior the element is to implement, or an array of such names.
// _bootstrap_: data set on the server-side and passed in to any models or collections that
//   may be instantiated as part of spinning up the views.
//
// **usage**
//
// ```
// .tab.hidden{ data: { views: ['showWhenActive', 'activateOnCoursesTabClicked', 'deactivateSiblings'] }}
// ```
StructureProfile.module('Views', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.addInitializer(function () {
        $("[data-view]").each(function (index, element) {
            var $element  = $(element),
                view      = $element.data("view");

            if (Module[view] != undefined) {
                Module[view].start();
            }
        });
    });

}, undefined);

