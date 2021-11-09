class CreateVertexRobots < ActiveRecord::Migration[6.1]
  def change
    create_table :vertex_robots do |t|
      t.string :vertex_gid
      t.string :webhook_secret
      t.json :external_settings
      t.json :vertices_attributes
      t.json :fields_attributes

      t.timestamps
    end
  end
end
