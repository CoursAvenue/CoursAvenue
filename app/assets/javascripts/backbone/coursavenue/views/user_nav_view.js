CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.UserNavView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'user_nav_view',

        initialize: function initialize () {
            this.model.on('change', this.render);
            // this.model.on('change', function() {
            //     this.render();
            // }.bind(this));
        },

        events: {
            'click [data-behavior=sign-up]': 'signUp',
            'click [data-behavior=sign-in]': 'signIn'
        },

        signIn: function signIn () {
            CoursAvenue.signIn();
        },

        signUp: function signUp () {
            CoursAvenue.signUp();
        },

        onRender: function onRender () {
            this.$('[data-behavior=drop-down]').dropDown();
        },

        serializeData: function serializeData () {
            var data = {
                logged_in: this.model.isLogged()
            }
            if (this.model.isLogged()) {
                _.extend(data, {
                    dashboard_user_path      : Routes.dashboard_user_path({ id: this.model.get('slug') }),
                    user_comments_path       : Routes.user_comments_path({ id: this.model.get('slug') }),
                    user_conversations_path  : Routes.user_conversations_path({ id: this.model.get('slug') }),
                    user_participations_path : Routes.user_participations_path({ id: this.model.get('slug') }),
                    destroy_user_session_path: Routes.destroy_user_session_path()
                });
            } else {
                _.extend(data, {
                    inscription_pro_structures_url: 'https://pro.coursavenue.com/etablissements/inscription'
                });
            }
            _.extend(data, this.model.toJSON());
            return data;
        }
    });
});
