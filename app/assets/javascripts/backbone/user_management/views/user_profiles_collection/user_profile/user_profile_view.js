
/* just a basic marionette view */
UserManagement.module('Views.UserProfilesCollection.UserProfile', function(Module, App, Backbone, Marionette, $, _) {

    Module.UserProfileView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'user_profile_view',
        tagName: 'tr',

        ui: {
            '$editable': "[data-behavior=editable]:not(:has('input'))",
            '$editing' : "[data-behavior=editable]:has('input')"
        },

        events: {
            'click @ui.$editable': 'startEditing',
        },

        finishEditing: function (e) {
            if (e.target.tagName === "INPUT") {
                return;
            }

            var $field = $(e.currentTarget);
            var $input = $field.find("input");

            text = $input.prop('value');
            $data = $("<div>").text(text);

            $field.html($data);
            $field.off('click', this.finishEditing);
            e.stopPropagation();
        },

        startEditing: function (e) {
            // stop editing other fields
            $(this.ui.$editing.selector).click();

            var $field = $(e.currentTarget);

            text = $field.text();
            $input = $("<input>").prop("value", text);

            $field.html($input);
            $field.on('click', this.finishEditing);
        }

//      onRender: function () {
//          this.$('[data-behavior=editable]').editable();
//          this.$('[data-behavior=editable]').on('save', function(){
//              var that = this;
//              setTimeout(function() {
//                  $(that).closest('td').next().find('[data-behavior=editable]').editable('show');
//              }, 200);
//          });
//      }
    });
});
