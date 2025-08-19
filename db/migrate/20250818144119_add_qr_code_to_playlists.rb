class AddQrCodeToPlaylists < ActiveRecord::Migration[8.0]
  def change
    add_reference :playlists, :qr_code, null: false, foreign_key: true
  end
end
