# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Rails.env.development?
  20.times do
    Skill.create({name: Faker::ProgrammingLanguage.name})
  end

  20.times do
    JobCategory.create({name: Faker::ProgrammingLanguage.name})
  end

  # create roles
  roles = [
  	{role_name: 'Admin', role_code: 'admin', authorities: nil, status: 'Active'},
  	{role_name: 'Super Admin', role_code: 'super_admin', authorities: nil, status: 'Active'},
  ]
  roles.each do |role|
  	Role.create(role)
  end
  # end create roles
  
end

