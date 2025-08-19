class SimplifyPlaylistModel < ActiveRecord::Migration[8.0]
  def change
    # Remove the name column from playlists
    remove_column :playlists, :name, :string

    # Remove any existing non-unique index on qr_code_id
    remove_index :playlists, :qr_code_id if index_exists?(:playlists, :qr_code_id)

    # Add a unique index to ensure one playlist per QR code
    add_index :playlists, :qr_code_id, unique: true
  end
end
