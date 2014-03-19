# encoding: utf-8
class InvitedUserMailer < ActionMailer::Base

  # View structures
  #   /invited_user_mailer/referrer_type/invited_user_type/recommand_friends.html.haml
  # if 'for' is specified:
  #   /invited_user_mailer/referrer_type/invited_user_type/recommand_friends_#{for}.html.haml
  layout 'email'

  default from: "\"L'équipe de CoursAvenue.com\" <contact@coursavenue.com>"

  def recommand_friends(invited_user)
    return unless invited_user.email_opt_in?
    @invited_user = invited_user
    @email_text   = invited_user.email_text
    @email        = invited_user.email
    @referrer     = invited_user.referrer
    @structure    = invited_user.structure
    template_view_file_name = (invited_user.for.nil? ? 'recommand_friends' : "recommand_friends_for_#{invited_user.for}")
    mail to: @email,
         subject: subject_for_recommand_friends(invited_user),
         template_name: "#{invited_user.referrer_type.downcase}/#{invited_user.type.split('::').last.downcase}/#{template_view_file_name}"
  end

  def inform_invitation_success(invited_user)
    # Don't send invitation success for jpo
    return if invited_user.for == 'jpo'
    @referrer      = invited_user.referrer
    @invited_email = invited_user.email
    @show_links    = true
    referrer_email = (invited_user.referrer_type == 'Structure' ? @referrer.main_contact.email : @referrer.email)
    mail to: referrer_email, subject: "Félicitations ! Votre parrainage a bien été pris en compte",
         template_name: "#{invited_user.referrer_type.downcase}/#{invited_user.type.split('::').last.downcase}/inform_invitation_success"
  end

  def send_invitation_stage_1(invited_user)
    return unless invited_user.email_opt_in?
    @invited_user  = invited_user
    @referrer      = invited_user.referrer
    @invited_email = invited_user.email
    @structure     = invited_user.structure
    template_view_file_name = (invited_user.for.nil? ? 'send_invitation_stage_1' : "recommand_friends_for_#{invited_user.for}_stage_1")
    mail to: @invited_email, subject: subject_for_recommand_friends_stage_1(invited_user),
         template_name: "#{invited_user.referrer_type.downcase}/#{invited_user.type.split('::').last.downcase}/#{template_view_file_name}"
  end

  def send_invitation_stage_2(invited_user)
    return unless invited_user.email_opt_in?
    @invited_user  = invited_user
    @referrer      = invited_user.referrer
    @invited_email = invited_user.email
    @structure     = invited_user.structure
    template_view_file_name = (invited_user.for.nil? ? 'send_invitation_stage_2' : "recommand_friends_for_#{invited_user.for}_stage_2")
    mail to: @invited_email, subject: subject_for_recommand_friends_stage_2(invited_user),
         template_name: "#{invited_user.referrer_type.downcase}/#{invited_user.type.split('::').last.downcase}/#{template_view_file_name}"
  end

  private

  # Email subject for first demand. Dependent of referrer, type and for
  # @param  invited_user
  #
  # @return String
  def subject_for_recommand_friends(invited_user)
    if invited_user.for == 'jpo'
      if invited_user.type == 'InvitedUser::Student'
        case invited_user.referrer_type
        # Student inviting another student
        when 'User'
          return "#{@referrer.name} vous invite à participer à un cours gratuit"
        # Teacher to students
        when 'Structure'
          return "#{@referrer.name} offre des cours gratuits : profitez-en pour inviter vos proches"
        end
      end
    else
      return "#{@referrer.name} vous invite à créer votre profil sur CoursAvenue"
    end
  end

  # Email subject for first demand. Dependent of referrer, type and for
  # @param  invited_user
  #
  # @return String
  def subject_for_recommand_friends_stage_1(invited_user)
    if invited_user.for == 'jpo'
      if invited_user.type == 'InvitedUser::Student'
        case invited_user.referrer_type
        # Student inviting another student
        when 'User'
          return "Réservez votre cours gratuit offert par #{@referrer.name}"
        # Teacher to students
        when 'Structure'
          return "Offrez un cours gratuit à vos proches avec #{@referrer.name}"
        end
      end
    else
      return "#{@referrer.name} vous invite à créer votre profil sur CoursAvenue"
    end
  end

  def subject_for_recommand_friends_stage_2(invited_user)
    if invited_user.for == 'jpo'
      if invited_user.type == 'InvitedUser::Student'
        case invited_user.referrer_type
        # Student inviting another student
        when 'User'
          return "Derniers jours pour réserver votre cours gratuit des 5-6 avril"
        # Teacher to students
        when 'Structure'
          return "Derniers jours pour offrir des cours gratuits à vos proches !"
        end
      end
    else
      return "#{@referrer.name} vous invite à créer votre profil sur CoursAvenue"
    end
  end
end
