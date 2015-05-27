unless Rails.env.test?
  Intercom.app_id      = ENV["INTERCOM_APP_ID"]
  Intercom.app_api_key = ENV['INTERCOM_API_KEY']
end

IntercomRails.config do |config|
  # == Intercom app_id
  #
  config.app_id = ENV["INTERCOM_APP_ID"]

  # == Intercom secret key
  # This is required to enable secure mode, you can find it on your Intercom
  # "security" configuration page.
  #
  config.api_secret = ENV['INTERCOM_API_SECRET']

  # == Intercom API Key
  # This is required for some Intercom rake tasks like importing your users;
  # you can generate one at https://app.intercom.io/apps/api_keys.
  #
  config.api_key = ENV['INTERCOM_API_KEY']

  # == Enabled Environments
  # Which environments is auto inclusion of the Javascript enabled for
  #
  config.enabled_environments = ["development", "production"]

  # == Current user method/variable
  # The method/variable that contains the logged in user in your controllers.
  # If it is `current_user` or `@user`, then you can ignore this
  #
  config.user.current = Proc.new { current_pro_admin }

  # == User model class
  # The class which defines your user model
  #
  config.user.model = Proc.new { Admin }

  # == Exclude users
  # A Proc that given a user returns true if the user should be excluded
  # from imports and Javascript inclusion, false otherwise.
  #
  # config.user.exclude_if = Proc.new { |user| user.deleted? }

  # == User Custom Data
  # A hash of additional data you wish to send about your users.
  # You can provide either a method name which will be sent to the current
  # user object, or a Proc which will be passed the current user.

  config.user.custom_data = {
    # We have this to ensure we can have an Admin and a User with the same email address and
    # none of them are overrided by the other.
    :user_id                   => Proc.new { |user| "Admin_#{user.id}" },
    :slug                      => Proc.new { |user| ((s = user.structure) ? s.slug : nil) },
    :name                      => Proc.new { |user| ((s = user.structure) ? s.name : user.name) },
    'nb avis'                  => Proc.new { |user| ((s = user.structure) ? s.comments_count : user.try(:comments).try(:count)) },
    'Villes'                   => Proc.new { |user| ((s = user.structure) ? s.places.map(&:city).map(&:name).join(', ').gsub(/^(.{250,}?).*$/m,'\1...') : nil) },
    'A confirmé son compte'    => Proc.new { |user| user.confirmed? },
    # Truncate string at 250 chars because we can't pass more than 255 chars
    'Disciplines_1'            => Proc.new { |user| ((s = user.structure) ? s.subjects.at_depth(0).uniq.map(&:name).join(', ').gsub(/^(.{250,}?).*$/m,'\1...') : nil) },
    'Disciplines_2'            => Proc.new { |user| ((s = user.structure) ? s.subjects.at_depth(2).map(&:parent).uniq.map(&:name).join(', ').gsub(/^(.{250,}?).*$/m,'\1...') : nil) },
    'Disciplines_3'            => Proc.new { |user| ((s = user.structure) ? s.subjects.at_depth(2).uniq.map(&:name).join(', ').gsub(/^(.{250,}?).*$/m,'\1...') : nil) },
    'Prof tag'                 => Proc.new { |user| ((s = user.structure) ? CrmSync.structure_status_for_intercom(s) : nil) },
    'Code postal'              => Proc.new { |user| ((s = user.structure) ?  s.zip_code : nil) },
    'last_comment_at'          => Proc.new { |user| ((s = user.structure) and s.comments.any? ?  s.comments.order('created_at DESC').first.created_at : nil) },
    'Email Opt-in'             => Proc.new { |user| user.monday_email_opt_in },
    'Type Offre'               => Proc.new { |user| ((s = user.structure) and s.premium? ?  (s.subscription.plan.website_plan? ? 'Site Internet' : 'Modules') : nil) },
    'Offre Premium'            => Proc.new { |user| ((s = user.structure) and s.subscription_plan.try(:active?) ?  s.subscription_plan.plan_type : nil) },
    'premium_ends_at'          => Proc.new { |user| ((s = user.structure) and s.subscription_plan.try(:active?) ?  s.subscription_plan.expires_at : nil) },
    # 0 s'il n'a pas mis sa CB,
    # 1 s'il a mis sa CB,
    # 2 si sa CB a un problème de validité (date expiration, coordonnées...)
    'CB B2B'                   => Proc.new do |user|
      if (s = user.structure) and s.subscription
        if s.subscription.stripe_subscription_id.present?
          1
        else
          0
        end
      end
    end,
    "trial_ends_at"             => Proc.new do |user|
      if (s = user.structure) and s.subscription
        s.subscription.trial_ends_at
      else
        nil
      end
    end,
    # 1 Si un prof a envoyé au moins 1 newsletter,
    # 2 s'il a au moins un brouillon mettre
    # 0 s'il n'a rien fait mettre
    "Newsletters"              => Proc.new do |user|
      if (s = user.structure)
        if s.newsletters.sent.count > 0
          1
        elsif s.newsletters.drafts.count > 0
          2
        else
          0
        end
      else
        nil
      end
    end,
    'Discipline 3 principale'  => Proc.new do |user|
      if (s = user.structure) and s.vertical_pages_breadcrumb.present?
        s.vertical_pages_breadcrumb.split('|').last.split(';').last
      else
        nil
      end
    end
  }

  # == User -> Company association
  # A Proc that given a user returns an array of companies
  # that the user belongs to.
  #
  # config.user.company_association = Proc.new { |user| user.companies.to_a }
  # config.user.company_association = Proc.new { |user| [user.company] }

  # == Current company method/variable
  # The method/variable that contains the current company for the current user,
  # in your controllers. 'Companies' are generic groupings of users, so this
  # could be a company, app or group.
  #
  # config.company.current = Proc.new { current_company }

  # == Company Custom Data
  # A hash of additional data you wish to send about a company.
  # This works the same as User custom data above.
  #
  # config.company.custom_data = {
  #   :number_of_messages => Proc.new { |app| app.messages.count },
  #   :is_interesting => :is_interesting?
  # }

  # == Company Plan name
  # This is the name of the plan a company is currently paying (or not paying) for.
  # e.g. Messaging, Free, Pro, etc.
  #
  # config.company.plan = Proc.new { |current_company| current_company.plan.name }

  # == Company Monthly Spend
  # This is the amount the company spends each month on your app. If your company
  # has a plan, it will set the 'total value' of that plan appropriately.
  #
  # config.company.monthly_spend = Proc.new { |current_company| current_company.plan.price }
  # config.company.monthly_spend = Proc.new { |current_company| (current_company.plan.price - current_company.subscription.discount) }

  # == Inbox Style
  # This enables the Intercom inbox which allows your users to read their
  # past conversations with your app, as well as start new ones. It is
  # disabled by default.
  #   * :default shows a small tab with a question mark icon on it
  #   * :custom attaches the inbox open event to an anchor with an
  #             id of #Intercom.
  #
  # config.inbox.style = :default
  # config.inbox.style = :custom
end
