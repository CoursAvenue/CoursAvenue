# encoding: utf-8
class UpdateSportsSubjects < ActiveRecord::Migration
  def up
    sports       = rename_subject 'sports', 'Sports & Arts martiaux'
    other_sports = sports.children.create name: 'Autres sports'
    delete_subject 'gymnastique-aerobic-fitness-danse-fitness'

    subj = update_parent 'automobile-sports-mecaniques', other_sports
    subj.children.map(&:destroy)
    subj = update_parent 'avion-sports-aeronautiques', other_sports
    subj.children.map(&:destroy)
    subj = update_parent 'course-a-pied-running-marathon', other_sports
    subj.children.map(&:destroy)
    subj = update_parent 'equitation', other_sports
    subj.children.map(&:destroy)
    subj = update_parent 'golf', other_sports
    subj.children.map(&:destroy)
    subj = update_parent 'randonnee', other_sports
    subj.children.map(&:destroy)
    subj = update_parent 'montagne', other_sports
    subj.children.map(&:destroy)
    subj = update_parent 'sports-extremes-et-insolites', other_sports
    subj.children.map(&:destroy)
    subj = update_parent 'sports-nautiques', other_sports
    subj.children.map(&:destroy)
    subj = update_parent 'velo-vtt', other_sports
    subj.children.map(&:destroy)

    delete_subject 'handisports'
    delete_subject 'triathlon'
    delete_subject 'course-a-pied'
    gym_fit = rename_subject 'gymnastique', 'Gymnastique & fitness'
    update_parent 'coaching-sportif', gym_fit
    update_parent 'pilates', gym_fit
    rename_subject 'gymnastiques', 'Gymnastique autres'
    plongee = update_parent 'plongee', 'autres-sports'
    plongee.children.map(&:destroy)
  end

  def down
  end

  def rename_subject slug, new_name
    subject      = Subject.find slug
    subject.name = new_name
    subject.save
    return subject
  end

  def delete_subject slug
    subject      = Subject.find slug
    subject.destroy
  end

  def delete_subjects slugs
    slugs.each do |slug|
      delete_subject(slug)
    end
  end

  def update_parent slug, parent_slug
    child  = Subject.find(slug)
    if parent_slug.is_a? String
      parent = Subject.find(parent_slug)
    else
      parent = parent_slug
    end
    child.parent = parent
    child.save
    return child
  end
end
