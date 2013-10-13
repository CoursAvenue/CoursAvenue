# encoding: utf-8
class RemoveChildTeenageSubject < ActiveRecord::Migration
  def association_subjects
    {
      "art-bricolage-enfants"                => 'bricolage--2',
      "calligraphie-enfants"                 => 'calligraphie',
      "taekwondo-enfants"                    => 'taekwondo',
      "massage-des-bebes"                    => 'massage',
      "cuisine-enfants"                      => 'cuisine-vins',
      "initiation-a-la-danse-enfants"        => 'danse',
      "claquettes-enfants"                   => 'claquettes',
      "danse-flamenco-enfants"               => 'flamenco',
      "danse-enfants"                        => 'danse',
      "danse-orientale-enfants"              => 'danse-orientale',
      "hip-hop-enfants"                      => 'hip-hop-break-dance',
      "swin-golf-enfants"                    => 'swin-golf',
      "gymnastique-douce-relaxation-enfants" => 'gymnastique-douce',
      "ecoles-et-conservatoires-de-musique"  => 'conservatoires-de-musique',
      "musique-enfants"                      => 'musique-chant',
      "patinage-roller-enfants"              => 'roller',
      "photo-multimedia-enfants"             => 'photo-video',
      "initiation-a-la-photo-enfants"        => 'photo-video',
      "improvisation-theatrale-enfants"      => 'improvisation-theatrale',
      "theatre-enfants"                      => 'theatre'
    }
  end
  def up
    # ----------------------- Create missing subjects
    danse = Subject.friendly.find('danse')
    danse.children.create name: 'Claquettes'
    danse.children.create name: 'Zumba'

    artisanat = Subject.friendly.find('art-artisanat')
    caligraphie = artisanat.children.create name: 'Calligraphie'
    caligraphie.children.create name: 'Calligraphie arabe'
    caligraphie.children.create name: 'Calligraphie chinoise & asiatique'
    caligraphie.children.create name: 'Calligraphie latine & contemporaine'
    caligraphie.children.create name: 'Découverte de la calligraphie'

    bar = ProgressBar.new(20)
    # ----------------------- Associating new subjects to children
    enfants_ados = Subject.friendly.find 'enfants-ados'
    association_subjects.each do |old, new|
      bar.increment!
      old_subject = Subject.friendly.find old
      new_subject = Subject.friendly.find new
      old_subject.structures.each do |structure|
        structure.subjects.delete old_subject
        structure.subjects << new_subject
        structure.save
        structure.index
      end
      old_subject.courses.each do |course|
        course.subjects.delete old_subject
        course.subjects << new_subject
        course.save
        course.index
      end
    end
    enfants_ados.descendants.map(&:destroy)
    enfants_ados.destroy
  end

  def down
  end
end
