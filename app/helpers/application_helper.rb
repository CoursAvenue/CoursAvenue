module ApplicationHelper

  def asset_url(asset)
    "#{request.protocol}#{request.host_with_port}#{asset_path(asset)}"
  end

  # Overriding Kaminari's method
  # https://github.com/amatsuda/kaminari/blob/master/lib/kaminari/helpers/action_view_extension.rb
  def page_entries_info(collection, options = {})
    if options[:pluralized_entry_name]
      entry_name = options[:pluralized_entry_name]
    else
      entry_name = if options[:entry_name]
        options[:entry_name]
      elsif collection.empty? || collection.is_a?(PaginatableArray)
        'entry'
      else
        if collection.respond_to? :model  # DataMapper
          collection.model.model_name.human.downcase
        else  # AR
          collection.model_name.human.downcase
        end
      end
      entry_name = entry_name.pluralize unless collection.total_count == 1
    end
    if collection.total_pages < 2
      t('helpers.page_entries_info.one_page.display_entries', entry_name: entry_name, count: collection.total_count)
    else
      first = collection.offset + 1
      last = collection.last_page? ? collection.total_count : collection.offset + collection.limit_value
      t('helpers.page_entries_info.more_pages.display_entries', entry_name: entry_name, first: first, last: last, total: collection.total_count)
    end.html_safe
  end

  def current_user_as_json
    UserSerializer.new(current_user, { structure: @structure }).to_json
  end

  def current_pro_admin_as_json
    if current_pro_admin.super_admin? and @structure
      AdminSerializer.new(@structure.main_contact).to_json
    else
      AdminSerializer.new(current_pro_admin).to_json
    end
  end
end
