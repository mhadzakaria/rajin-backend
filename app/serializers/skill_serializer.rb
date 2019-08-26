class SkillSerializer < ApplicationSerializer
  attributes :id, :name, :picture

   def picture
    return picture_details(object.picture.try(:file_url))
  end
end
