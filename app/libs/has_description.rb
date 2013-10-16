module HasDescription

  def self.included(base)
    base.instance_eval do
      include ::HasSubjects::InstanceMethods
    end
  end

  module InstanceMethods
  end
end
