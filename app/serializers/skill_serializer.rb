class SkillSerializer < ApplicationSerializer
  attributes :id, :name, :picture

   def picture(data = [])
    if object.picture.present? && object.picture.file_url.present?
      datum = {}
      datum[:file_type] = object.picture.file_type
      datum[:file_url] = picture_details(object.picture.file_url)

      data << datum
    end

    return data
  end
end
