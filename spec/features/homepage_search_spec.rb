require 'rails_helper'

describe 'homepage search', type: :feature do
  include SolrSpecHelper

  # let(:structure)    { FactoryGirl.create(:structure_with_place) }

  before(:all) do
    solr_setup
    @structure = FactoryGirl.create(:structure_with_place)
  end

  after(:all) do
    Structure.remove_all_from_index!
  end

  it 'goes to the homepage', js: true do
    visit root_path

    within('#home-page-form') do
      click_button('submit_search_form')
    end

    find('#search-results')

    expect(page).to have_content(@structure.name)
  end

  it 'finds the indexed structure', js: true do
    visit structure_path(@structure)

    expect(page).to have_content(@structure.name)
  end
end
