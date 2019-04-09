module ApplicationHelper
  def date_formater(date, format = '%d/%m/%Y')
    return date.try("strftime", format)
  end

  def submit_button_label(object = nil)
    label = object.try(:new_record?) ? 'Create' : 'Update'
    return "#{label} #{object.class.name.underscore.titleize}"
  end

  def sidebar_active?(section_name)
    return "active" if controller_name.eql?(section_name)
  end

  def user_notifications
    current_user.notifications
  end
end
