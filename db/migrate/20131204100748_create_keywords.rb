# encoding: utf-8
class CreateKeywords < ActiveRecord::Migration
  def up
    create_table :keywords do |t|
      t.string :name

      t.timestamps
    end

    Subject.find_each do |subject|
      subject.name.split(',').each do |name|
        Keyword.create(name: name.strip.capitalize)
      end
    end
    Keyword.create(name: 'Tango argentin')
  end

  def down
    drop_table :keywords
  end
end
