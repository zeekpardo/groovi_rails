class CreateQrCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :qr_codes do |t|
      t.references :account, null: false, foreign_key: true
      t.references :linkable, polymorphic: true, null: false
      t.string :name, null: false
      t.string :short_url, null: false
      t.jsonb :design_settings, default: {}
      t.integer :download_count, default: 0, null: false
      t.integer :scan_count, default: 0, null: false
      t.references :created_by, foreign_key: {to_table: :users}

      t.timestamps

      t.index [:account_id, :created_at]
      t.index :short_url
      t.index [:linkable_type, :linkable_id]
    end
  end
end
