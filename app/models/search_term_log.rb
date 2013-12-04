class SearchTermLog < ActiveRecord::Base
  attr_accessible :name, :count

  def increment!
    self.update_column :count, (self.count + 1)
  end

  def self.create_log(_name)
    log = SearchTermLog.find_or_create_by(name: _name)
    log.increment!
  end

end
