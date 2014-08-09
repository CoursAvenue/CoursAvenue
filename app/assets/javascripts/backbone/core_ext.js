Backbone.Marionette.Renderer.render = function(template, data){
    var rendered;

    // if the template is blank, then we just want "render nothing"
    if (template === "") return "";

    // otherwise, if we can't find the template in our JST
    if (!JST[template]) {
        if (_.isFunction(template)) { // it may be a compiled HBS function
            rendered = template(data);
        } else {
            throw "Template '" + template + "' not found!";
        }
    }

    return rendered || JST[template](data);
}

var _module = Marionette.Module;
var _prototype = Marionette.Module.prototype;

// A simple module system, used to create privacy and encapsulation in
// Marionette applications
Marionette.Module = function(moduleName, modulePath, app){
    this.moduleName = moduleName;
    this.modulePath = modulePath;

    // store sub-modules
    this.submodules = {};

    this._setupInitializersAndFinalizers();

    // store the configuration for this module
    this.app = app;
    this.startWithParent = true;

    this.triggerMethod = Marionette.triggerMethod;
};

_.extend(Marionette.Module, _module, {
    _getModule: function(parentModule, moduleName, app, def, args){
        // Get an existing module of this name if we have one
        var module = parentModule[moduleName], modulePath;

        if (parentModule.modulePath !== undefined) {
            modulePath = parentModule.modulePath + "." + moduleName;
        } else if (parentModule.moduleName !== undefined) {
            // EDGECASE: prepending parrent module name");
            modulePath = parentModule.moduleName + moduleName;
        } else {
            modulePath = moduleName; // module is a top level module, like Views
        }

        if (!module){
            // Create a new module if we don't have one
            module = new Marionette.Module(moduleName, modulePath, app);
            parentModule[moduleName] = module;
            // store the module on the parent
            parentModule.submodules[moduleName] = module;
        }

        return module;
    }
});
_.extend(Marionette.Module.prototype, _prototype);

_.extend(Marionette.Module.prototype, {
    templateDirname: function () {
        var modules = this.modulePath.split('.');
        modules.shift(); // remove the top level module ("Views", "Models")

        var dirpath = _.inject(modules, function (memo, module) {
            memo += module.replace(/([A-Z])/g, '_$1').toLowerCase().slice(1) + '/';

            return memo;
        }, "");

        var app_name = this.app.slug.replace(/-/g, '_');

        return 'backbone/' + app_name + '/templates/' + dirpath;
    }
});

var _trigger = Marionette.View.prototype.trigger;

/* event locking for our evented Marionette party party */
/* this is kind of complicated a little. There are two kinds of
* locks, explicit and implicit. Lock can be called like,
*
*   this.lock("event:name"); // creates an implicit lock
*   this.lock("event:name", "method_name"); // explicit lock
*
* The implicit lock for each event has a count, which is incremented
* or decremented whenever lock or unlock is called with one argument.
* When they are called with an extra argument, this creates a named
* lock idempotently. The named lock can only be removed by calling
* unlock with two arguments.
*
* So, if three methods call lock('event'), then the given event
* will be ignored until it has been triggered three times. If
* lock('event', 'bob') is called, then the given event will be ignored
* until unlock('event', 'bob') is called.
*   */
_.extend(Marionette.View.prototype, {
    _locks: {},

    trigger: function () {
        var args = Array.prototype.slice.call(arguments);

        return this.tryTrigger(args);
    },

    /* used internally, this method will unset a once lock */
    tryTrigger: function (args) {
        var message = args[0];

        if (! this.isLocked(message)) {
            _trigger.apply(this, args);
        } else {
            this.unlock(message);
        }

        return this;
    },

    /* @param message is the name of an event to be ignored
     * @param source is the name of a method that created
     * the lock.
     * */
    lock: function (message, source) {
        if (this.hasLock(source, message)) {
            return;
        }

        if (this._locks[message] === undefined) {
            this._locks[message] = { count: 0, sources: {} };
        }

        if (source !== undefined) {
            this._locks[message].sources[source] = true;
        } else {
            this._locks[message].count += 1;
        }
    },

    /* @param message the name of an event to stop ignoring
     * @param source the name of an explicit event.
     *
     * If source is provided, this event removes that lock.
     * Otherwise it only decrements the count of implicit locks.
     * */
    unlock: function (message, source) {
        if (this.isLocked(message)) {

            if (source !== undefined) {
                delete this._locks[message].sources[source];
            } else {
                if (this._locks[message].count > 0) {
                    this._locks[message].count -= 1;
                }
            }
        }
    },

    hasLock: function (source, message) {
        if (source === undefined) return false;

        return this.isLocked(message) && this._locks[message].sources[source];
    },

    isLocked: function (message) {

        return this._locks[message] && (this._locks[message].count > 0 || _.keys(this._locks[message].sources).length > 0);
    }
});

/* convenience method */
_.extend(_, {
    capitalize: function (word) {
        if (!word) { return ''; }
        return word.charAt(0).toUpperCase() + word.slice(1);
    },

    plural_map:{
        "oxen"  : "ox",
        "people": "person"
    },

    getSingularMap: function getSingularMap () {
        if (_._singular_map === undefined) {
            _._singular_map = _.invert(this.plural_map);
        }

        return _.clone(_._singular_map);
    },

    singularize: function (word) {
        var last        = word.length - 1;
        var ends_with_s = word.lastIndexOf("s") === last;
        var is_plural   = ends_with_s || _.has(_.plural_map, word);

        if (!is_plural) {
            return word;
        }

        return (ends_with_s)? word.substring(0, last) : _.plural_map[word];
    },

    pluralize: function (word) {
        var last        = word.length - 1,
            ends_with_s = word.lastIndexOf("s") === last,
            is_plural   = ends_with_s || _.has(_.plural_map, word),
            map;

        if (is_plural) {
            return word;
        }

        map = _.getSingularMap();

        return (map[word] === undefined)? word + 's' : map[word];
    },

    camelize: function (word) {
        return word.replace (/(?:^|[-_])(\w)/g, function (_, c) {
            return c ? c.toUpperCase () : '';
        });
    },

    ensureArray: function ensureArray(a, b, n) {
        if (arguments.length === 0) return []; //no args, ret []
        if (arguments.length === 1) { //single argument
            if (a === undefined || a === null) return []; // undefined or null, ret []
            if (Array.isArray(a)) return a; // isArray, return it
        }
        return Array.prototype.slice.call(arguments); //return array with copy of all arguments
    }
});


/* when building an Application, the NullApplication will be
 * returned if the given app root was not detected */
Marionette.NullApplication = Marionette.Application.extend({
    module: function (moduleNames, moduleDefinition) { /* NOP */ },
    addRegions: function (options) { /* NOP */ },
    addInitializer: function (initializer) { /* NOP */ },
    start: function () { /* NOP */ },
});

Marionette.renderNothing = function renderNothing (view, args) {
    view.isDestroyed = false;
    view.triggerMethod("before:render", view);
    view.triggerMethod("before:render", view);

    view.bindUIElements();

    view.triggerMethod("render", view);
    view.triggerMethod("render", view);

    return view;
}

_.extend(Marionette.Application.prototype, {

    /* for use in query strings */
    root:   function() {
        if (this.root === undefined) {
            throw "CoursAvenue Applications must override slug"
        }

        return this.slug + '-root';
    },

    /* methods for returning the relevant jQuery collections */
    $root: function() {
        if (this.root === undefined) {
            throw "CoursAvenue Applications must override slug"
        }

        return $('[data-type=' + this.root() + ']');
    },

    /* A filteredSearch should only start if it detects
     * an element whose data-type is the same as its
     * root property.
     * @throw the root was found to be non-unique on the page */
    detectRoot: function() {
        var result = this.$root().length;

        if (result > 1) {
            throw {
                message: 'Application->detectRoot: ' + this.root() + ' element should be unique'
            }
        }

        return result > 0;
    },

    loader: function() { return this.slug + '-loader'; },

    /* Return the element in which the application will be appended */
    $loader: function() {
        return $('[data-type=' + this.loader() + ']');
    },

    /* changes the app's slug and ensures that all modules reference
     * this app, instead of another app */
    rebrand: function (slug, resource) {
        // if the slug does not exist, then we won't rebrand
        if (!$("[data-type=" + slug + "-root]").length > 0) {
            return new Marionette.NullApplication();
        }

        var new_app = jQuery.extend(true, {}, this);

        new_app._initRegionManager();
        new_app._initCallbacks = new Marionette.Callbacks();

        // the two lines above seem to be enough to reset the
        // application. However, the next three lines might
        // become necessary later. Who knows!
        //
        // new_app.vent = new Backbone.Wreqr.EventAggregator();
        // new_app.commands = new Backbone.Wreqr.Commands();
        // new_app.reqres = new Backbone.Wreqr.RequestResponse();

        new_app.slug     = slug;
        new_app.resource = resource;

        // We may need to loop through all regions
        delete new_app.mainRegion;

        /* walk breadth first through the submodules tree, ensuring that their
         * back-references are all pointing to the new app */
        var modules = _.values(new_app.submodules);
        var i;

        for (i = 0; i < modules.length; i += 1) {
            var module = modules[i];
            module.app = new_app;

            // gather all the submodules
            _.each(_.values(module.submodules), function (submodule) {
                modules.push(submodule);
            });
        }

        /* for every template we have that matches an existing template
         * find the corresponding view and extend it in place, to use
         * our template rather than theirs */

        var template_dirname = new_app.Views.templateDirname();

        // find all JST templates that contain our dirname
        var templates = _.reduce(_.keys(JST), function (memo, key) {
            var key_parts = key.split(template_dirname);

            // 'backbone/open_doors/templates/template_name'.split('backbone/open_doors/templates/')
            // returns ['', 'template_name']
            if (key_parts.length > 1) {
                memo.push(_.last(key_parts));
            }

            return memo;
        }, []);

        // for each of the matching templates,
        // extend the corresponding view in place
        _.each(templates, function (template) {
            var module_path  = _.map(template.split('/'), _.camelize);
            var view_name    = module_path.pop();
            var parent_views = [];

            var module = _.reduce(module_path, function (module, submodule) {
                module = module[submodule];

                // Looking for SomethingCollectionView to be able to override a
                // template without reimplementing its view.js
                var views = _.filter(_.keys(module), function (key) {
                    // if it is a SomethingView
                    if (key.match(/^[A-Z].*View$/)) {

                        var view = module[key];

                        // and it is a collection (ie has an childview)
                        if (view.prototype.childView) {
                            var childview_template = view.prototype.childView.prototype.template;

                            // and the childview's template matches our template
                            if (childview_template.match(template)) {
                                parent_views.push({ module: module, key: key }); // make a note
                            }
                        }
                    }

                    return;
                });

                return module;
            }, new_app.Views);

            // extend the view in place with our dirname
            module[view_name] = module[view_name].extend({
                template: template_dirname + template
            });

            _.each(parent_views, function (pair) {
                var parent_module = pair.module;
                var key           = pair.key;

                parent_module[key] = parent_module[key].extend({
                    childView: module[view_name]
                });
            });
        });

        return new_app;
    },

});
