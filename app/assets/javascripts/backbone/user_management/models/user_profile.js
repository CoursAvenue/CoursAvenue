
/* just a basic backbone model */
UserManagement.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.UserProfile = Backbone.Model.extend({
        url: function () {
            return this.collection.url.basename + this.collection.url.resource + '/' + this.get("id");
        }
    });
});
