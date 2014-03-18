# Define methods to augment hstore fields to be booleans
#
#
module HstoreHelper

  def define_boolean_accessor_for(store_field_name, *keys)
    # Add methods to have hstore attributes return booleans
    keys.each do |key|
      # Commented because it is not being used yet
      # scope "has_#{key}", ->(value) { where("#{store_field_name.to_s} @> hstore(?, ?)", key, value) }

      define_method("#{key}") do
        if self.send(store_field_name) && self.send(store_field_name).has_key?(key.to_s) then
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
end
