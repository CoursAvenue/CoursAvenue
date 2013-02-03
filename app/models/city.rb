# encoding: utf-8
class City < ActiveRecord::Base
  has_many :structures

  has_attached_file :no_result_image

  attr_accessible :name, :short_name, :no_result_image

  validates :name, :short_name, uniqueness: true
end
