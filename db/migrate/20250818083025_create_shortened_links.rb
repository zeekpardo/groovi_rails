class CreateShortenedLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :shortened_links do |t|
      t.references :account, null: false, foreign_key: true
      t.string :short_code, null: false
      t.string :custom_slug
      t.string :title
      t.text :description
      t.string :schema_type, null: false
      t.text :target_value, null: false
      t.integer :click_count, default: 0, null: false
      t.jsonb :metadata, default: {}
      t.jsonb :settings, default: {}
      t.datetime :expires_at
      t.boolean :active, default: true, null: false
      t.references :created_by, foreign_key: {to_table: :users}

      t.timestamps

      t.index :short_code, unique: true
      t.index :custom_slug, unique: true, where: "custom_slug IS NOT NULL"
      t.index [:account_id, :created_at]
      t.index :schema_type
      t.index :active
    end
  end
end
