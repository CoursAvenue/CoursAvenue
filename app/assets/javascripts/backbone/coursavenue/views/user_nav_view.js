CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.UserNavView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'user_nav_view',

        initialize: function initialize () {
            this.model.on('change', this.render);
        },

        events: {
            'click [data-behavior=sign-up]': 'signUp',
            'click [data-behavior=sign-in]': 'signIn'
        },

        signIn: function signIn (event, options) {
            options = options || { show_admin_form: true };
            CoursAvenue.signIn(options);
        },

        signUp: function signUp () {
            CoursAvenue.signUp();
        },

        onRender: function onRender () {
            this.$('[data-behavior=drop-down]').dropDown();
            if (location.hash == '#connexion') {
                this.signIn({}, { show_admin_form: false});
            }
        },

        serializeData: function serializeData () {
            var data = {
                logged_in                            : this.model.isLogged(),
                on_sleeping_page                     : window.on_sleeping_page,
                take_control_url                     : window.take_control_url,
                pages_faq_users_url                  : Routes.pages_faq_users_path(),
                on_discovery_pass_pages              : window.on_discovery_pass_pages,
                discovery_passes_url                 : Routes.discovery_passes_path()
            }
            if (this.model.isLogged()) {
                _.extend(data, {
                    dashboard_user_path               : Routes.dashboard_user_path({ id: this.model.get('slug') }),
                    edit_user_path                    : Routes.edit_user_path({ id: this.model.get('slug') }),
                    new_user_sponsorship_path         : Routes.new_user_sponsorship_path({ id: this.model.get('slug') }),
                    user_participation_requests_path  : Routes.user_participation_requests_path({ id: this.model.get('slug') }),
                    new_user_sponsorship_path         : Routes.new_user_sponsorship_path({ id: this.model.get('slug') }),
                    user_comments_path                : Routes.user_comments_path({ id: this.model.get('slug') }),
                    user_passions_path                : Routes.user_passions_path({ id: this.model.get('slug') }),
                    user_followings_path              : Routes.user_followings_path({ id: this.model.get('slug') }),
                    user_conversations_path           : Routes.user_conversations_path({ id: this.model.get('slug') }),
                    new_user_invited_user_path        : Routes.new_user_invited_user_path({ id: this.model.get('slug') }),
                    destroy_user_session_path         : Routes.destroy_user_session_path()
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
