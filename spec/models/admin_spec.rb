# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin do
  subject { admin }
  context :admin do
    let(:admin) { FactoryGirl.build(:admin) }

    it { should be_valid }
    it 'should not be super_admin' do
      expect(admin.super_admin).to be false
    end
  end

  context :facebook do
    class Accounts < Struct.new(:name, :link); end

    class Fb_User
      def fetch
        self
      end

      def accounts
        [ Accounts.new('CA', 'http://facebook.com/CoursAvenue') ]
      end
    end

    describe 'Connection with Facebook' do
      describe '#facebook_pages' do

        context 'not connected from Facebook' do
          let(:admin) { FactoryGirl.build(:admin) }
          it 'should return nothing' do
            expect(admin.facebook_pages).to be_empty
          end
        end

        context 'connected from Facebook' do
          context 'without any pages' do
            let(:admin) { FactoryGirl.build(:admin_from_facebook) }

            it 'should return the pages administrated by the admin' do
              allow(FbGraph::User).to receive(:me).and_return(Fb_User.new)

              expect(admin.facebook_pages).not_to be_empty
            end
          end
        end

      end
    end
  end
end
