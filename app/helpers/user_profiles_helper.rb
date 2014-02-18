# encoding: utf-8
module UserProfilesHelper

  def join_user_profile_tags user_profile
    user_profile.tags.collect do |tag|
      content_tag(:span, tag.name, class: 'taggy--tag')
    end.join('').html_safe
  end
end
