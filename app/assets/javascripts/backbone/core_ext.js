Backbone.Marionette.Renderer.render = function(template, data){
    if (template === "") return "";
    if (!JST[template]) throw "Template '" + template + "' not found!";
    return JST[template](data);
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
        console.log("EDGECASE: prepending parrent module name");
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
  },
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

        var app_name = this.app.slug.replace(/-/g, '');

        return 'backbone/ ' + app_name + '/templates/' + dirpath;
    }
});

var _trigger = Marionette.View.prototype.trigger;

/* event locking for our evented Marionette party party */
_.extend(Marionette.View.prototype, {
    _locks: {},
    _once_locks: {},

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
            this.unlockOnce(message);
        }

        return this;
    },

    lock: function (message) {
        this._locks[message] = true;
    },

    unlock: function (message) {
        this._locks[message] = false;
    },

    lockOnce: function (message) {
        if (this._once_locks[message] === undefined) {
            this._once_locks[message] = { count: 0 };
        }

        this._once_locks[message].count += 1;
    },

    unlockOnce: function (message) {
        if (this.isLockedOnce(message)) {
            this._once_locks[message].count -= 1;
        }
    },

    isLocked: function (message) {
        return this._locks[message] || this.isLockedOnce(message);
    },

    isLockedOnce: function (message) {
        return this._once_locks[message] && this._once_locks[message].count > 0;
    }
});

