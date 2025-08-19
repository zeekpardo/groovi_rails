class Account < ApplicationRecord
  has_prefix_id :acct

  has_many :shortened_links, dependent: :destroy
  has_many :playlists, dependent: :destroy
  has_many :qr_codes, dependent: :destroy

  include Billing
  include Domains
  include Transfer
  include Types
end
