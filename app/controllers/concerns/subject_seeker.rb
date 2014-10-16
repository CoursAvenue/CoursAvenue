module SubjectSeeker
  extend ActiveSupport::Concern

  # [get_descendants description]
  # @params
  #    ids: subject ids separeted by comas (123,124,53)
  # @return json:
  #     Danse - Danse de salon :
  #           - Salsa
  #           - Zumba
  #           - ...
  #     Cuisine - ...:
  #           - ...
  def get_descendants(params)
    @subjects = params[:ids].split(',').map do |id|
      Subject.fetch_by_id_or_slug(*id)
    end
    @descendants = []
    @subjects.each do |parent_subject|
      parent_subject.descendants.at_depth(1).each do |first_descendant|
        obj                = {}
        parent_name        = first_descendant.name
        obj[parent_name] ||= []
        first_descendant.children.order('name ASC').each do |second_descendant|
          obj[parent_name] << second_descendant
        end
        @descendants << obj
      end
    end
    @descendants = @descendants.sort_by { |subj| subj.keys[0] }
    return @descendants
  end

end
