class CreatePlaylistItems < ActiveRecord::Migration[8.0]
  def change
    create_table :playlist_items do |t|
      t.references :playlist, null: false, foreign_key: true
      t.string :schema_type, null: false
      t.string :title, null: false
      t.text :target_value, null: false
      t.integer :position, null: false
      t.integer :click_count, default: 0, null: false
      t.boolean :active, default: true, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :playlist_items, [:playlist_id, :position]
    add_index :playlist_items, :schema_type
    add_index :playlist_items, [:playlist_id, :active]
  end
end
