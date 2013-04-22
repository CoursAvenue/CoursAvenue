module ActsAsCommentable

  def self.included(base)
    base.instance_eval do
      include ::ActsAsCommentable::InstanceMethods
    end
  end

  module InstanceMethods
    def rating
      if read_attribute(:rating)
        '%.1f' % read_attribute(:rating)
      else
        read_attribute(:rating)
      end
    end
  end
end
