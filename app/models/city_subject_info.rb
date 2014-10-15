class CitySubjectInfo < ActiveRecord::Base
  belongs_to :city
  belongs_to :subject

  attr_accessible :title, :description, :city_id, :subject_id,
                  :where_to_practice, :where_to_suit_up, :average_price, :tips


  def self.load(_city_id, _subject_id)
    city_subject_info = CitySubjectInfo.where( CitySubjectInfo.arel_table[:city_id].eq(_city_id).and(
                                               CitySubjectInfo.arel_table[:subject_id].eq(_subject_id)) ).first
    if city_subject_info.nil?
      subject = Subject.fetch_by_id_or_slug(_subject_id)
      if subject.parent
        _subject_id = subject.parent.id
        city_subject_info = CitySubjectInfo.where( CitySubjectInfo.arel_table[:city_id].eq(_city_id).and(
                                                   CitySubjectInfo.arel_table[:subject_id].eq(_subject_id)) ).first
      end
    end
    city_subject_info
  end

end
