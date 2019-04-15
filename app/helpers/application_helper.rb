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

  def download_button
    url = request.url.include?('?') ? request.url.split('?').join('.csv?') : "#{request.url}.csv "
    "<a class='btn btn-success' href='#{url}'>Download CSV</a>".html_safe
  end

  def auth_option_checked?(obj, auth_type, type)
    auth = obj.authorities[auth_type].to_h
    if auth[type] == "true"
      return true
    else
      return false
    end
  end

  def data_is_true?(data)
    if data.eql?("true")
      return "<span class='badge badge-pill badge-success round-badge'><i class='fa fa-check'></i></span>".html_safe
    else
      return "<span class='badge badge-pill badge-danger round-badge'><i class='fa fa-times'></i></span>".html_safe
    end
  end

end
