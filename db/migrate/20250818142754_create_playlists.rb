class CreatePlaylists < ActiveRecord::Migration[8.0]
  def change
    create_table :playlists do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :short_code, null: false
      t.string :playlist_type, default: "sequential", null: false
      t.integer :current_position, default: 0, null: false
      t.boolean :active, default: true, null: false
      t.jsonb :settings, default: {}
      t.references :created_by, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end

    add_index :playlists, :short_code, unique: true
    add_index :playlists, [:account_id, :created_at]
    add_index :playlists, :playlist_type
  end
end
