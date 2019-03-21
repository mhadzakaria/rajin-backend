module ApplicationHelper
  def date_formater(date, format = '%d/%m/%Y')
    return date.try("strftime", format)
  end
end
