class AdminAbility
  include CanCan::Ability

  def initialize(admin)
    if admin
      if admin.super_admin?
        can :manage, :all
      elsif !admin.active
        can :read, admin.structure
        can :read, admin.structure.places
        can :read, admin.structure.courses.where{active == true}
        can :manage, admin.structure.courses.where{active == false}
        can :manage, admin
      else
        can :manage, admin.structure
        can :manage, admin.structure.places
        can :manage, admin.structure.courses
        can :manage, admin.structure.teachers
        can :manage, admin.structure.invited_teachers
        can :manage, admin
      end
      can :create, Place
    end
    can :create, Structure

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
