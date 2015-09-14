require 'rails_helper'

feature 'the signup process' do
  scenario 'it redirects to the course creation page' do
    setup_signup
    structure_name =  "#{ Faker::Name.name } institut"
    lesson_type = ['lesson', 'training', 'private'].sample

    visit new_pro_registration_url
    within('form') do
      fill_in('structure_registration_form_structure_name', with: structure_name)
      Subject.roots.stars.pluck(:name).each { |s| select(s, from: 'parent-subjects') }
      choose('structure_registration_form[course_type]',    option: lesson_type)
      fill_in('structure_registration_form_admin_email',    with: Faker::Internet.email)
      fill_in('structure_registration_form_admin_password', with: Faker::Internet.password)
      click_button('Enregistrer')
    end

    expect(page.current_path).to eq(new_course_pro_registrations_path(
      course_type: lesson_type, id: structure_name.parameterize))
  end

  def setup_signup
    _subjects = 5.times.map { FactoryGirl.create(:subject, :star, :root) }
    _children = _subjects.map { |s| FactoryGirl.create(:subject, parent: s, depth: 2) }
  end
end
