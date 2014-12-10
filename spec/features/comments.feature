# -*- encoding : utf-8 -*-
require 'rails_helper'

describe "Posts a comment", type: :feature, js: true do

  let(:structure) { FactoryGirl.create(:structure) }

  it "succeeds" do
    visit new_structure_comment_path(structure)
    within("#session") do
      fill_in 'Login', :with => 'user@example.com'
      fill_in 'Password', :with => 'password'
    end
    click_link 'Sign in'
    expect(page).to have_content 'Success'
  end
end
