class Passion < ActiveRecord::Base
  belongs_to :user
  belongs_to :subject
  belongs_to :parent_subject, class_name: 'Subject', foreign_key: :parent_subject_id

  FREQUENCIES  = ['passions.frequencies.everyday',
                  'passions.frequencies.two_to_five_a_week',
                  'passions.frequencies.once_a_week',
                  'passions.frequencies.once_a_month',
                  'passions.frequencies.less_than_10_times_a_year']

  attr_accessible :frequency, :practiced, :expectation_ids, :reason_ids,
                  :subject, :parent_subject, :subject_id, :parent_subject_id

  scope :practiced, -> { where(practiced: true) }
  scope :wanted,    -> { where(practiced: false) }

  validates :subject_id, uniqueness: {scope: :user_id}

  # ---------------------------- Simulating reason and Levels
  def reason_ids= _reasons
    if _reasons.is_a? Array
      write_attribute :reason_ids, _reasons.reject{|level| level.blank?}.join(',')
    else
      write_attribute :reason_ids, _reasons
    end
  end

  def reasons= _reasons
    if _reasons.is_a? Array
      write_attribute :reason_ids, _reasons.map(&:id).join(',')
    elsif _reasons.is_a? reason
      write_attribute :reason_ids, _reasons.id.to_s
    end
  end

  def reasons
    return [] unless reason_ids.present?
    self.reason_ids.map{ |reason_id| reason.find(reason_id) }
  end

  def reason_ids
    return [] unless read_attribute(:reason_ids)
    read_attribute(:reason_ids).split(',').map(&:to_i) if read_attribute(:reason_ids)
  end

  # ---------------------------- Simulating expectation and Levels
  def expectation_ids= _expectations
    if _expectations.is_a? Array
      write_attribute :expectation_ids, _expectations.reject{|level| level.blank?}.join(',')
    else
      write_attribute :expectation_ids, _expectations
    end
  end

  def expectations= _expectations
    if _expectations.is_a? Array
      write_attribute :expectation_ids, _expectations.map(&:id).join(',')
    elsif _expectations.is_a? expectation
      write_attribute :expectation_ids, _expectations.id.to_s
    end
  end

  def expectations
    return [] unless expectation_ids.present?
    self.expectation_ids.map{ |expectation_id| expectation.find(reason_id) }
  end

  def expectation_ids
    return [] unless read_attribute(:expectation_ids)
    read_attribute(:expectation_ids).split(',').map(&:to_i) if read_attribute(:expectation_ids)
  end
end
