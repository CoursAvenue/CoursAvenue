
/* Behaviours
 * ----------
 *
 * The Behaviors module is a collection of functions that each take an element and attach
 * some event handlers to it, or to the document. Each behavior is meant to be stateless,
 * general, and as simple as possible. By combining behaviors on an object, we can easily
 * create more complicated DOM interactions, without the need to instantiate a full-fledged
 * Marionette view.
 *
 * Behaviors are intended to be like the css rules of javascript. If an element is supposed
 * to stick to the top of the page, or expand on click, or play an animation until it gets
 * a particular event, the element should use a behavior. Long lists of behaviors that
 * commonly occur together can be collected into Components, but the moment state enters
 * into the picture a View should be used.
 *
 * **data API**
 *
 * _behaviors_: a name of a behavior the element is to implement, or an array of such names.
 *
 * **submodules**
 *
 * Submodules of the Behaviors module each represent one behavior. The names of submodules
 * should be a substring of the data-behavior that invokes it. These submodules must also
 * implement two functions: `attachTo` and a matcher function.
 *
 * **usage**
 *
 * ```
 * .tab.hidden{ data: { behaviors: ['showWhenActive', 'activateOnCoursesTabClicked', 'deactivateSiblings'] }}
 * ```
 */
Daedalus.module('Behaviors', function(Module, App, Backbone, Marionette, $, _, undefined) {
    Module.matchers = [];

    Module.addInitializer(function () {
        $("[data-behaviors]").each(function (index, element) {
            var $element  = $(element),
                behaviors = $element.data("behaviors");

            if (!_.isArray(behaviors)) {
                behaviors = [behaviors];
            }

            _.each(behaviors, _.partial(attachBehaviors, element));
        });
    });

    /* ***
     * ### \#attachBehaviors
     *
     * given an element and a data-behavior, attaches a behavior to the element
     * if one can be found matching the given data-behavior
     */
    var attachBehaviors = function attachBehaviors (element, behavior_name) {
        var behavior = behavior_name,
            attacher = false,
            i = 0, matcher;

        // TODO using a while loop because we can't have pretty things
        while (attacher === false && i < Module.matchers.length) {
            matcher = Module.matchers[i];
            attacher = matcher(behavior);
            i++;
        }

        if (attacher !== false) {
            attacher(element);
        }
    };

    /* ***
     * ### \#registerMatcher
     *
     * submodules must define a matcher function that will be called to determine
     * which behavior to use for a given data-behavior entry. The matcher
     * function should take a string and return false or an object containing
     * the parsed options to be passed in to that module's attachTo function.
     * For example, The activateOn behaviour looks for data-behaviors like `/activateOn(.*)/`
     * and returns `{ event: \1 }`. A data-behavior like
     * `activateOnCoursesTabClicked` matches the activateOn behavior with
     * `{ event: CoursesTabClicked }` as its parameter.
     *
     * Currently, matchers are tested in the order they are registered, so
     * try to make sure your matcher starts with some unique string. My convention
     * has been to make the matcher begin with the name of the submodule
     * explicitly. Since the submodules share a namespace this guarantees
     * no overlap in the regexes.
     */
    Module.registerMatcher = function registerMatcher (matcher, submodule) {

        /* a matcher is a function that:
         *
         * - takes a string
         * - returns false or the matching submodule's attachTo function, partially applied with the arguments from the match.
         *
         * Module.matchers is an array of functions that close on each submodule
         * and matcher. A function f in Module.matchers will,
         *
         * - evaluate the matcher against a given string
         * - partially apply the return value against the submodule's `attachTo` function
         * - return the attacher, i.e. the partially applied `attachTo` function
         */
        Module.matchers.push(function (string) {

            var options  = matcher(string), // <-- evaluate the given matcher
                attacher = false;

            if (options !== false) {
                attacher = _.partial(submodule.attachTo, options); //
            }

            return attacher;
        });
    };

}, undefined);

