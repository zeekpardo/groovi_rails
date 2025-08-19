class CreateLinkClicks < ActiveRecord::Migration[8.0]
  def change
    create_table :link_clicks do |t|
      t.references :shortened_link, null: false, foreign_key: true
      t.inet :ip_address
      t.string :user_agent
      t.string :referrer
      t.string :country
      t.string :city
      t.string :device_type
      t.string :browser
      t.jsonb :metadata, default: {}

      t.datetime :clicked_at, null: false

      t.index :clicked_at
      t.index [:shortened_link_id, :clicked_at]
      t.index :country
      t.index :device_type
    end
  end
end
