class ::InvitedUser::Teacher < InvitedUser

  belongs_to :structure, foreign_key: :referrer_id

end
