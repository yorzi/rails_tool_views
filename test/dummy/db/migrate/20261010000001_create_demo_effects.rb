class CreateDemoEffects < ActiveRecord::Migration[7.2]
  def change
    create_table :demo_effects do |t|
      t.string :surface_id, null: false
      t.string :value, null: false
      t.timestamps
    end
  end
end
