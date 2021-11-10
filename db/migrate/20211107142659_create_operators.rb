class CreateOperators < ActiveRecord::Migration[6.1]
  def change
    create_table :operators do |t|
      t.belongs_to :vertex_robot
      t.string :vertex_gid
      t.string :webhook_url
      t.json :entries
      t.json :vertex
      t.json :journey_user
      t.string :journey_sn

      t.timestamps
    end
  end
end
