class SubjectsController < ApplicationController
  respond_to :json

  def index
    @subjects = Subject.order('name ASC').all.map{|s| {name: s.name, slug: s.slug} }
    respond_to do |format|
      format.json { render json: @subjects.to_json }
    end
  end

  # Params:
  #    ids: subject ids separeted by comas (123,124,53)
  #  Returns json:
  #     Danse - Danse de salon :
  #           - Salsa
  #           - Zumba
  #           - ...
  #     Cuisine - ...:
  #           - ...
  def descendants
    @subjects = params[:ids].split(',').map{ |id| Subject.find(id) }
    @descendants = []
    @subjects.each do |parent_subject|
      parent_subject.descendants.at_depth(1).each do |first_descendant|
        obj                = {}
        parent_name        = first_descendant.name
        obj[parent_name] ||= []
        first_descendant.children.each do |second_descendant|
          obj[parent_name] << second_descendant
        end
        @descendants << obj
      end
    end
    @descendants = @descendants.sort_by{|subj| subj.keys[0]}
    respond_to do |format|
      if params[:callback]
        format.js { render :json => {descendants: @descendants.to_json}, callback: params[:callback] }
      else
        format.json { render json: @descendants.to_json }
      end
    end
  end

  def tree
    if params[:parent]
      subject_roots = [Subject.find(params[:parent])]
    else
      subject_roots = Subject.roots
    end
    @subjects = {}
    subject_roots.each do |root|
      @subjects[root.name] = {}
      root.children.each do |sub_root|
        @subjects[root.name][sub_root.name] = []
        sub_root.children.each do |sub_sub_root|
          @subjects[root.name][sub_root.name] << sub_sub_root.name
        end
      end
    end
    respond_to do |format|
      format.json { render json: @subjects.to_json }
    end
  end

  def tree_2
    if params[:parent]
      subject_roots = [Subject.find(params[:parent])]
    else
      subject_roots = Subject.roots
    end
    @subjects = {}
    subject_roots.each do |root|
      @subjects["#{root.name} - #{root.slug} (#{root.courses.count})"] = {}
      root.children.each do |sub_root|
        @subjects["#{root.name} - #{root.slug} (#{root.courses.count})"]["#{sub_root.name} - #{sub_root.slug} (#{sub_root.courses.count})"] = []
        sub_root.children.each do |sub_sub_root|
          @subjects["#{root.name} - #{root.slug} (#{root.courses.count})"]["#{sub_root.name} - #{sub_root.slug} (#{sub_root.courses.count})"] << "#{sub_sub_root.name} - #{sub_sub_root.slug} (#{sub_sub_root.courses.count})"
        end
      end
    end
    respond_to do |format|
      format.json { render json: @subjects.to_json }
    end
  end
end
