class InvitedUser::Student < InvitedUser

  belongs_to :user, foreign_key: :referrer_id

end
