class RoleSerializer < ApplicationSerializer
  attributes :id, :role_name, :role_code, :authorities, :status
end
