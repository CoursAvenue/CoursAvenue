# -*- encoding : utf-8 -*-

FactoryGirl.define do
  factory :unfinished_comment, class: 'UnfinishedResource::Comment' do
    transient do
      commentable_id false
    end

    fields {
      {
        "from"                      => "recommendation-page",
        "utf8"                      => "✓",
        "subject"                   => Faker::Lorem.sentence,
        "submitted"                 => "false",
        "comment[email]"            => Faker::Internet.email,
        "comment[title]"            => Faker::Lorem.words,
        "private_message"           => Faker::Lorem.paragraph,
        "comment[content]"          => Faker::Lorem.paragraphs,
        "authenticity_token"        => Faker::Number.number(10),
        "comment[author_name]"      => Faker::Name.name,
        "comment[course_name]"      => Faker::Lorem.words,
        "comment[subject_ids][]"    => "",

        # pass in a commentable_id if you want to cause a collision
        "comment[commentable_id]"   => (commentable_id)? commentable_id : @helpers.valid_commentable_id,
        "comment[commentable_type]" => "Structure"
      }
    }

    class << @helpers
      def valid_commentable_id
        FactoryGirl.create(:structure).id
      end
    end

  end

end
