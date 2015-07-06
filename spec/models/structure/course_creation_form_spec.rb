require 'rails_helper'

describe Structure::CourseCreationForm do
  context 'validations' do
    it { should validate_presence_of(:structure_id) }

    it { should validate_presence_of(:course_name) }
    it { should validate_presence_of(:course_type) }
    it { should validate_presence_of(:course_subject_ids) }

    it { should validate_presence_of(:place_name) }
    it { should validate_presence_of(:place_street) }
    it { should validate_presence_of(:place_zip_code) }
    it { should validate_presence_of(:place_city_id) }
  end

  let!(:structure) { FactoryGirl.create(:structure) }

  describe '#save' do
    context 'when not valid' do
      subject { Structure::CourseCreationForm.new(structure_id: structure.slug) }

      it { expect(subject.save).to be_falsy }

      it "doesn't create the place" do
        expect { subject.save }.to_not change { Place.count }
      end

      it "doesn't create the course" do
        expect { subject.save }.to_not change { Course.count }
      end
    end

    context 'when valid' do
      subject { Structure::CourseCreationForm.new(valid_params(structure)) }

      it 'creates the place' do
        expect { subject.save }.to change { Place.count }.by(1)
      end

      it 'creates the course' do
        expect { subject.save }.to change { Course.count }.by(1)
      end
    end
  end

  def valid_params(structure)
    subject_ = FactoryGirl.create(:subject_children)
    price = FactoryGirl.build(:registration)
    city = FactoryGirl.create(:city)

    {
      structure_id: structure.slug,

      course_name: Faker::Name.name + ' course',
      course_type: ["Course::Lesson", "Course::Training", "Course::Private"].sample,
      course_subject_ids: [subject_.id],
      course_prices_attributes: [price.attributes.compact],
      course_frequency: Course::COURSE_FREQUENCIES.sample,

      place_name: Faker::Name.name + ' place',
      place_street: Faker::Address.street_address,
      place_zip_code: Faker::Address.zip_code,
      place_city_id: city.id
    }
  end
end
