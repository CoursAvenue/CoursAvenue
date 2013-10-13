class FixDuplicateSlugs < ActiveRecord::Migration
  def up
    s = Subject.friendly.find('bonnes-manieres');         s.destroy
    s = Subject.friendly.find('art-de-recevoir');         s.destroy
    s = Subject.friendly.find('savoir-vivre');            s.destroy
    s = Subject.friendly.find('tarots-tirages');          s.destroy
    s = Subject.friendly.find('nutrition');               s.destroy
    s = Subject.friendly.find('degustation-de-truffes');  s.destroy
    s = Subject.friendly.find('degustation-de-vins');     s.destroy
    s = Subject.friendly.find('pochoirs');                s.destroy

    Subject.where{slug =~ '%--2'}.each do |subject|
      subject.slug = subject.slug[0..(subject.slug.length - 4)]
      subject.save
    end
  end

  def down
  end
end
