# Define methods to augment hstore fields to be booleans
#
#
module Concerns
  module HstoreHelper
    extend ActiveSupport::Concern

    included do
      def self.define_boolean_accessor_for(store_field_name, *keys)
        # Add methods to have hstore attributes return booleans
        keys.each do |key|
          # Commented because it is not being used yet
          # scope "has_#{key}", ->(value) { where("#{store_field_name.to_s} @> hstore(?, ?)", key, value) }

          define_method("#{key}") do
            if self.send(store_field_name) && self.send(store_field_name).has_key?(key.to_s)
              ActiveRecord::ConnectionAdapters::Column.value_to_boolean(self.send(store_field_name)[key.to_s])
            else
              nil
            end
          end
          define_method("#{key}?") do
            send key.to_sym
          end
        end
      end

      def self.define_array_accessor_for(store_field_name, *keys)
        # Add methods to have hstore attributes return booleans
        keys.each do |key|
          # Commented because it is not being used yet
          # scope "has_#{key}", ->(value) { where("#{store_field_name.to_s} @> hstore(?, ?)", key, value) }

          define_method("#{key}") do
            if self.send(store_field_name) &&
              self.send(store_field_name).has_key?(key.to_s) &&
              self.send(store_field_name)[key.to_s].present?
              if self.send(store_field_name)[key.to_s].is_a? Array
                self.send(store_field_name)[key.to_s]
              else
                JSON::parse self.send(store_field_name)[key.to_s]
              end
            else
              []
            end
          end
          define_method("#{key}?") do
            send key.to_sym
          end
        end
      end
    end
  end
end
