require 'rails_helper'

describe InvitedUserMailer do

  ######################################################################
  # Structure                                                          #
  ######################################################################
  context 'When a Structure invites someone' do
    let(:structure) { FactoryGirl.create(:structure) }
    # To students
    ######################################################################
    # There is none

    # To other structure
    ######################################################################
    context 'other structure' do
      let(:invited_user) { InvitedUser::Teacher.new(referrer_id: structure.id, referrer_type: 'Structure' , email: 'azdopj@azpodja.azd') }
      describe 'recommand_friends' do
        let(:mail) { InvitedUserMailer.recommand_friends(invited_user) }

        it 'renders the headers' do
          expect(mail.subject).to eq "#{structure.name} vous invite à créer votre profil sur CoursAvenue"
        end
        it 'renders the right link in body' do
          expect(mail.body.encoded).to match(inscription_pro_structures_url(subdomain: 'pro'))
        end
      end

      describe 'send_invitation_stage_1' do
        let(:mail) { InvitedUserMailer.send_invitation_stage_1(invited_user) }

        it 'renders the headers' do
          expect(mail.subject).to eq "#{structure.name} vous invite à créer votre profil sur CoursAvenue"
        end
        it 'renders the right link in body' do
          expect(mail.body.encoded).to match(inscription_pro_structures_url(subdomain: 'pro'))
        end
      end

      describe 'send_invitation_stage_2' do
        let(:mail) { InvitedUserMailer.send_invitation_stage_2(invited_user) }

        it 'renders the headers' do
          expect(mail.subject).to eq "#{structure.name} vous invite à créer votre profil sur CoursAvenue"
        end
        it 'renders the right link in body' do
          expect(mail.body.encoded).to match(inscription_pro_structures_url(subdomain: 'pro'))
        end
      end
    end
  end

  ######################################################################
  # Users                                                              #
  ######################################################################
  context 'When a User invites someone' do
    let(:user) { FactoryGirl.create(:user) }

    # To other students
    ######################################################################
    context 'other students' do
      let(:invited_user) { InvitedUser::Student.new(referrer_id: user.id, referrer_type: 'User' , email: 'azdopj@azpodja.azd') }
      describe 'recommand_friends' do
        let(:mail) { InvitedUserMailer.recommand_friends(invited_user) }

        it 'renders the headers' do
          expect(mail.subject).to eq "#{user.name} vous invite à créer votre profil sur CoursAvenue"
        end
        it 'renders the right link in body' do
          expect(mail.body.encoded).to match(new_user_registration_url(subdomain: 'www'))
        end
      end

      describe 'send_invitation_stage_1' do
        let(:mail) { InvitedUserMailer.send_invitation_stage_1(invited_user) }

        it 'renders the headers' do
          expect(mail.subject).to eq "#{user.name} vous invite à créer votre profil sur CoursAvenue"
        end
        it 'renders the right link in body' do
          expect(mail.body.encoded).to match(new_user_registration_url(subdomain: 'www'))
        end
      end

      describe 'send_invitation_stage_2' do
        let(:mail) { InvitedUserMailer.send_invitation_stage_2(invited_user) }

        it 'renders the headers' do
          expect(mail.subject).to eq "#{user.name} vous invite à créer votre profil sur CoursAvenue"
        end
        it 'renders the right link in body' do
          expect(mail.body.encoded).to match(new_user_registration_url(subdomain: 'www'))
        end
      end
    end
  end
end
