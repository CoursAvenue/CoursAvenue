class FixDuplicateSlugs < ActiveRecord::Migration
  def up
    s = Subject.find('bonnes-manieres');         s.destroy
    s = Subject.find('art-de-recevoir');         s.destroy
    s = Subject.find('savoir-vivre');            s.destroy
    s = Subject.find('tarots-tirages');          s.destroy
    s = Subject.find('nutrition');               s.destroy
    s = Subject.find('degustation-de-truffes');  s.destroy
    s = Subject.find('degustation-de-vins');     s.destroy
    s = Subject.find('pochoirs');                s.destroy

    Subject.where{slug =~ '%--2'}.each do |subject|
      subject.slug = subject.slug[0..(subject.slug.length - 4)]
      subject.save
    end
  end

  def down
  end
end
