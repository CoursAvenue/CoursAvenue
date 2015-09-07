CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _) {

    Module.UserNavView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'user_nav_view',

        initialize: function initialize () {
            this.model.on('change', this.render);
            _.bindAll(this, 'signUp', 'signIn');
            $('body').on('click', '[data-behavior=sign-up]', this.signUp);
            $('body').on('click', '[data-behavior=sign-in]', this.signIn);
        },

        signIn: function signIn (event, options) {
            options = options || {};
            CoursAvenue.signIn(options);
        },

        signUp: function signUp (event) {
            if ($(event.currentTarget).data('title')) {
                CoursAvenue.signUp({ title: $(event.currentTarget).data('title') });
            } else {
                CoursAvenue.signUp();
            }
        },

        onRender: function onRender () {
            if (location.hash == '#connexion') {
                this.signIn({}, {});
            }
        },

        serializeData: function serializeData () {
            var data = {
                logged_in          : this.model.isLogged(),
                on_sleeping_page   : window.on_sleeping_page,
                take_control_url   : window.take_control_url,
                pages_faq_users_url: Routes.pages_faq_users_path(),
                pro_structures_url : 'https://pro.coursavenue.com'
            }
            if (CoursAvenue.currentAdmin().isLogged() && CoursAvenue.currentAdmin().get('structure_slug')) {
                _.extend(data, { admin_logged_in: true,
                                 structure_path  : Routes.dashboard_pro_structure_path({ id: CoursAvenue.currentAdmin().get('structure_slug') })
                               });
            } else if (this.model.isLogged()) {
                _.extend(data, {
                    dashboard_user_path               : Routes.dashboard_user_path({ id: this.model.get('slug') }),
                    edit_user_path                    : Routes.edit_user_path({ id: this.model.get('slug') }),
                    user_participation_requests_path  : Routes.user_participation_requests_path({ id: this.model.get('slug') }),
                    user_comments_path                : Routes.user_comments_path({ id: this.model.get('slug') }),
                    user_followings_path              : Routes.user_followings_path({ id: this.model.get('slug') }),
                    user_conversations_path           : Routes.user_conversations_path({ id: this.model.get('slug') }),
                    new_user_invited_user_path        : Routes.new_user_invited_user_path({ id: this.model.get('slug') }),
                    destroy_user_session_path         : Routes.destroy_user_session_path()
                });
            }
            _.extend(data, this.model.toJSON());
            return data;
        }
    });
});
