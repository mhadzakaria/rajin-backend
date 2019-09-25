# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Rails.env.development?
  20.times do
    skill = Skill.find_or_initialize_by({name: Faker::ProgrammingLanguage.name})
    skill.save
  end

  20.times do
    job_cat = JobCategory.find_or_initialize_by({name: Faker::ProgrammingLanguage.name})
    job_cat.save
  end
end

# roles = [
#   {role_name: 'Admin', role_code: 'admin', status: 'Active'},
#   {role_name: 'Super Admin', role_code: 'super_admin', status: 'Active'},
# ]

roles = [{"role_name"=>"Super Admin", "role_code"=>"super_admin", "authorities"=>{"jobs_auth"=>{"view"=>"true", "add"=>"true", "edit"=>"true", "delete"=>"true"}, "job_categories_auth"=>{"view"=>"true", "add"=>"true", "edit"=>"true", "delete"=>"true"}, "job_requests_auth"=>{"view"=>"true", "add"=>"true", "edit"=>"true", "delete"=>"true"}, "skills_auth"=>{"view"=>"true", "add"=>"true", "edit"=>"true", "delete"=>"true"}, "companies_auth"=>{"view"=>"true", "add"=>"true", "edit"=>"true", "delete"=>"true"}, "school_partners_auth"=>{"view"=>"true", "add"=>"true", "edit"=>"true", "delete"=>"true"}, "pictures_auth"=>{"view"=>"true", "add"=>"true", "edit"=>"true", "delete"=>"true"}, "mentors_auth"=>{"view"=>"true", "add"=>"true", "edit"=>"true", "delete"=>"true"}, "users_auth"=>{"view"=>"true", "add"=>"true", "edit"=>"true", "delete"=>"true"}, "roles_auth"=>{"view"=>"true", "add"=>"true", "edit"=>"true", "delete"=>"true"}, "coin_packages_auth"=>{"view"=>"true", "add"=>"true", "edit"=>"true", "delete"=>"true"}, "orders_auth"=>{"view"=>"true", "add"=>"true", "edit"=>"true", "delete"=>"true"}}, "status"=>"Active"}]

roles.each do |role|
  authorities = role['authorities']
  role.delete('authorities')

  roles = Role.find_or_initialize_by(role)
  roles.authorities = authorities
  roles.save
end

users = User.where.not(role_id: [roles.id, nil])
users.each do |user|
  puts "UPDATE USER #{user.email}"
  user.role_id = roles.id
  user.save
end

User.create(email: "admin@rajin.com", nickname: "Admin", first_name: "Admin", last_name: "1", role: Role.find_by(role_code: 'super_admin'), password: "password")

# CREATE OR INIT PACKAGE
coin_packages = [
  {coin: 20, amount: 25},
  {coin: 30, amount: 30}
]

coin_packages.each do |coin_package|
  coin = CoinPackage.find_or_initialize_by(coin_package)
  coin.save
end

