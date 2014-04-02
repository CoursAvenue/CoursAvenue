
/* just a basic backbone model */
UserManagement.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.UserProfile = Backbone.Model.extend({
        url: function () {
            var resource = this.collection.url.resource;
            var id = this.get("id");

            // TODO it seems to me backbone should already know how to do this...
            if (id === undefined && this.get("new")) {
                id = "";
                this.set("new", false);
                resource = resource + ".json";
            } else {
                resource = resource + '/' + id;
            }

            // we were having a problem at some point where the URL would sometimes
            // be mes-eleves/? and sometimes just mes-eleves?
            //
            // this was causing the url method to return mes-eleves/mes-eleves/:id,
            // so we are just sanitizing away the duplicate
            resource = this.sanitizeUrl(resource);

            return this.collection.url.basename + resource;
        },

        /* @pre assuming the resource is a string of the form "/resource/:id" */
        sanitizeUrl: function sanitizeUrl (resource) {
            var basename_parts = this.collection.url.basename.split("/"),
                last_part      = basename_parts.slice(-1),
                resource_parts = resource.split("/"),
                first_part     = resource_parts.slice(1, 2); // the array is like ["", "resource", "id"]

            // if the basename_parts already contain the resource,
            if (_.isEqual(first_part, last_part)) {
                resource_parts = ["", resource_parts.slice(-1)]; // then we just want the :id part
            }

            return resource_parts.join("/");
        }

    });
});
