class RemoveCoachingSportif < ActiveRecord::Migration
  def up
    coaching     = Subject.find 'coaching-sportif'
    coaching_gym = Subject.find 'coaching-sportif-gym'
    (coaching.structures + coaching.courses).each do |instance|
      instance.subjects.delete(coaching)
      instance.subjects << coaching_gym
    end
    coaching.delete
  end

  def down
  end
end
