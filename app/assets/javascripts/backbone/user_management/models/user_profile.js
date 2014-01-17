
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

            return this.collection.url.basename + resource;
        }
    });
});
