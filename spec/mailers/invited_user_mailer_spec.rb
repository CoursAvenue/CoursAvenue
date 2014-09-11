require 'spec_helper'

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
          expect(mail.body.encoded).to match(inscription_pro_structures_url(subdomain: CoursAvenue::Application::PRO_SUBDOMAIN))
        end
      end

      describe 'send_invitation_stage_1' do
        let(:mail) { InvitedUserMailer.send_invitation_stage_1(invited_user) }

        it 'renders the headers' do
          expect(mail.subject).to eq "#{structure.name} vous invite à créer votre profil sur CoursAvenue"
        end
        it 'renders the right link in body' do
          expect(mail.body.encoded).to match(inscription_pro_structures_url(subdomain: CoursAvenue::Application::PRO_SUBDOMAIN))
        end
      end

      describe 'send_invitation_stage_2' do
        let(:mail) { InvitedUserMailer.send_invitation_stage_2(invited_user) }

        it 'renders the headers' do
          expect(mail.subject).to eq "#{structure.name} vous invite à créer votre profil sur CoursAvenue"
        end
        it 'renders the right link in body' do
          expect(mail.body.encoded).to match(inscription_pro_structures_url(subdomain: CoursAvenue::Application::PRO_SUBDOMAIN))
        end
      end
    end
    # To students for JPO
    ######################################################################
    # context 'jpo' do
    #   let(:invited_user) { InvitedUser::Student.new(invitation_for: 'jpo', referrer_id: structure.id, referrer_type: 'Structure' , email: 'azdopj@azpodja.azd') }
    #   describe 'recommand_friends' do
    #     let(:mail) { InvitedUserMailer.recommand_friends(invited_user) }

    #     it 'renders the headers' do
    #       expect(mail.subject).to eq "#{structure.name} offre des cours gratuits : profitez-en pour inviter vos proches"
    #     end

    #     it 'renders the right link in body' do
    #       expect(mail.body.encoded).to match(invite_entourage_to_jpo_page_users_url(subdomain: CoursAvenue::Application::WWW_SUBDOMAIN))
    #     end
    #   end

    #   describe 'send_invitation_stage_1' do
    #     let(:mail) { InvitedUserMailer.send_invitation_stage_1(invited_user) }

    #     it 'renders the headers' do
    #       expect(mail.subject).to eq "Offrez un cours gratuit à vos proches avec #{structure.name}"
    #     end
    #     it 'renders the right link in body' do
    #       expect(mail.body.encoded).to match(invite_entourage_to_jpo_page_users_url(subdomain: CoursAvenue::Application::WWW_SUBDOMAIN))
    #     end
    #   end

    #   describe 'send_invitation_stage_2' do
    #     let(:mail) { InvitedUserMailer.send_invitation_stage_2(invited_user) }

    #     it 'renders the headers' do
    #       expect(mail.subject).to eq "Derniers jours pour offrir des cours gratuits à vos proches !"
    #     end
    #     it 'renders the right link in body' do
    #       expect(mail.body.encoded).to match(invite_entourage_to_jpo_page_users_url(subdomain: CoursAvenue::Application::WWW_SUBDOMAIN))
    #     end
    #   end
    # end
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
          expect(mail.body.encoded).to match(new_user_registration_url(subdomain: CoursAvenue::Application::WWW_SUBDOMAIN))
        end
      end

      describe 'send_invitation_stage_1' do
        let(:mail) { InvitedUserMailer.send_invitation_stage_1(invited_user) }

        it 'renders the headers' do
          expect(mail.subject).to eq "#{user.name} vous invite à créer votre profil sur CoursAvenue"
        end
        it 'renders the right link in body' do
          expect(mail.body.encoded).to match(new_user_registration_url(subdomain: CoursAvenue::Application::WWW_SUBDOMAIN))
        end
      end

      describe 'send_invitation_stage_2' do
        let(:mail) { InvitedUserMailer.send_invitation_stage_2(invited_user) }

        it 'renders the headers' do
          expect(mail.subject).to eq "#{user.name} vous invite à créer votre profil sur CoursAvenue"
        end
        it 'renders the right link in body' do
          expect(mail.body.encoded).to match(new_user_registration_url(subdomain: CoursAvenue::Application::WWW_SUBDOMAIN))
        end
      end
    end

    # To other structure
    ######################################################################
    # There is none

    # To students for JPO
    ######################################################################
    # context 'jpo' do
    #   let(:invited_user) { InvitedUser::Student.new(invitation_for: 'jpo', referrer_id: user.id, referrer_type: 'User' , email: 'azdopj@azpodja.azd') }
    #   describe 'recommand_friends' do
    #     let(:mail) { InvitedUserMailer.recommand_friends(invited_user) }

    #     it 'renders the headers' do
    #       expect(mail.subject).to eq "#{user.name} vous invite à participer à un cours gratuit"
    #     end

    #     it 'renders the right link in body' do
    #       expect(mail.body.encoded).to match(root_url(@structure, subdomain: CoursAvenue::Application::WWW_SUBDOMAIN))
    #     end
    #   end

    #   describe 'send_invitation_stage_1' do
    #     let(:mail) { InvitedUserMailer.send_invitation_stage_1(invited_user) }

    #     it 'renders the headers' do
    #       expect(mail.subject).to eq "Réservez votre cours gratuit offert par #{user.name}"
    #     end
    #     it 'renders the right link in body' do
    #       expect(mail.body.encoded).to match(root_url(subdomain: CoursAvenue::Application::WWW_SUBDOMAIN))
    #     end
    #   end

    #   describe 'send_invitation_stage_2' do
    #     let(:mail) { InvitedUserMailer.send_invitation_stage_2(invited_user) }

    #     it 'renders the headers' do
    #       expect(mail.subject).to eq "Derniers jours pour réserver votre cours gratuit des 5-6 avril"
    #     end
    #     it 'renders the right link in body' do
    #       expect(mail.body.encoded).to match(root_url(subdomain: CoursAvenue::Application::WWW_SUBDOMAIN))
    #     end
    #   end
    # end
  end
end
