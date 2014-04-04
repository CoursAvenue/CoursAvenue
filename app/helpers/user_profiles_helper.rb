# encoding: utf-8
module UserProfilesHelper

  def readable_phone_number phone_number
    if phone_number
      _phone_number = phone_number.gsub(' ', '')
      "#{_phone_number[0..1]} #{_phone_number[2..3]} #{_phone_number[4..5]} #{_phone_number[6..7]} #{_phone_number[8..9]}"
    end
  end

  def join_user_profile_tags user_profile
    user_profile.tags.collect do |tag|
      content_tag(:span, tag.name, class: 'taggy--tag')
    end.join('').html_safe
  end
end
