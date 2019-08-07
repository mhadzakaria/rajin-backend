namespace :skills do
  desc "Update user skill_ids to has_many skills"
  task(:skill_ids_to_relation => :environment) do
		User.all.each do |p|
		  if p.attributes['skill_ids'].present?
		    puts "update user #{p.email}"
		    puts p.attributes['skill_ids'].to_sentence

		    skills = []
		    p.attributes['skill_ids'].each do |id|
		      nsk = p.level_skills.new
		      nsk.skill_id = id
		      nsk.level = 5
		      skills << nsk
		    end
		    p.level_skills = skills
		    p.save

		    puts p.level_skills.map(&:skill_id).to_sentence
		  end
		end
	end
end