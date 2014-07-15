class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    # Add http if there is not
    value = value.downcase
    unless value[/^https?/]
      value = "http://#{value}"
      record[attribute] = value
    end
    unless !!value.match(/^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?/)
      record.errors[attribute] << (options[:message] || I18n.t('validators.url.errors.messages.invalid'))
    end
  end
end
