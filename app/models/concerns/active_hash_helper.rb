# Define basic method of a has_many relationship but applied to ActiveHash models
# Usage:
#     ActiveHashHelper.define_has_many_for :funding_type
#
# Will define on the models the following method:
#   model.funding_type_ids=
#   model.funding_types=
#   model.funding_type_ids
#   model.funding_types
#
# @author [Nima]
#
module Concerns
  module ActiveHashHelper
    extend ActiveSupport::Concern

    included do
      def self.define_has_many_for(key)
        key_s            = key.to_s
        associated_model = key_s.classify.constantize

        # Ex: audience
        # def audience_ids=
        # @param  Array of ids or a string
        #
        # @return Boolean
        define_method("#{key_s}_ids=") do |values|
          if values.is_a? Array
            write_attribute "#{key_s}_ids".to_sym, values.reject{|value| value.blank?}.join(',')
          else
            write_attribute "#{key_s}_ids".to_sym, values
          end
        end

        # def audiences=
        # @param  Array of Audience or single Audience
        #
        # @return Boolean
        define_method "#{key_s}s=" do |values|
          if values.is_a? Array
            write_attribute "#{key_s}_ids".to_sym, values.map(&:id).join(',')
          elsif values.is_a? associated_model
            write_attribute "#{key_s}_ids".to_sym, values.id.to_s
          end
        end

        # def audiences
        #
        # @return Array of Audience
        define_method "#{key_s}s" do
          return [] unless key.present?
          self.send("#{key_s}_ids".to_sym).map{ |val| associated_model.find(val) }
        end

        # def audience_ids
        #
        # @return Array of ids
        define_method "#{key_s}_ids" do
          return [] unless read_attribute("#{key_s}_ids".to_sym)
          read_attribute("#{key_s}_ids".to_sym).split(',').map(&:to_i) if read_attribute("#{key_s}_ids".to_sym)
        end
      end
    end
  end
end
