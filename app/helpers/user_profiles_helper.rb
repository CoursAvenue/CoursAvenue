# encoding: utf-8
module UserProfilesHelper

  def readable_phone_number phone_number
    if phone_number
      "#{phone_number[0..1]} #{phone_number[2..3]} #{phone_number[4..5]} #{phone_number[6..7]} #{phone_number[8..9]}"
    end
  end

  def join_user_profile_tags user_profile
    user_profile.tags.collect do |tag|
      content_tag(:span, tag.name, class: 'taggy--tag')
    end.join('').html_safe
  end
end
