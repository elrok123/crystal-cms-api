require "kemalyst-model/adapter/pg"

class Home < Kemalyst::Model
  adapter pg

  # id, created_at and updated_at columns are automatically created for you.
  sql_mapping({
  })

end
