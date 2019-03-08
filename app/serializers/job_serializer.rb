class JobSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :payment_term, :amount, :payment_type, :full_address, :city, :postcode, :state, :country, :start_date, :end_date, :latitude, :longitude, :status, :job_category_id, :skills

  # def skills
  # 	if object.skill_ids.present?
	 #  	skills = object.skill_ids.tr('[]', '').split(',').map(&:to_i)
	 #  	skills.each do |skill|
	 #  		Skill.find(skill).name
	 #  	end
	 #  end
  # end

  def skills(data = [])
  	skills = object.skills
    object.skills.each do |skill|
      datum = {}
      datum[:id] = skill.id
      datum[:name] = skill.name
      # datum[:skill_logo_url]  = skill.picture.file_url
      # datum[:skill_logo_type] = skill.picture.file_type
      data << datum
    end
    
    return data
  end
end