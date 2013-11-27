
/* just a basic backbone model */
UserManagement.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.UserProfilesCollection = CoursAvenue.Models.PaginatedCollection.extend({
        model: Models.UserProfile,

        url: function () {
            console.log("UserProfilesCollection->url");

            return "mes-eleves.json";
        }
    });
});
