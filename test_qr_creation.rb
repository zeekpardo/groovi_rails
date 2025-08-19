# Test script to create QR codes
user = User.first
account = Account.first
ActsAsTenant.current_tenant = account

puts "Creating QR codes for user: #{user.email}"
puts "Account: #{account.name}"

# Create QR Code 1: With custom slug
puts "\n=== Creating QR Code 1: With Custom Slug ==="
shortened_link_1 = ShortenedLink.create!(
  title: "Test QR with Custom Slug",
  target_value: "https://example.com/custom-test",
  schema_type: "url",
  custom_slug: "my-custom-slug",
  account: account
)

qr_code_1 = QrCode.create!(
  name: "QR Code with Custom Slug",
  linkable: shortened_link_1,
  account: account,
  created_by: user,
  design_settings: {
    foreground_color: "#000000",
    background_color: "#FFFFFF",
    dot_style: "rounded",
    corner_style: "rounded"
  }
)

# Create playlist for QR Code 1
playlist_1 = Playlist.create!(
  qr_code: qr_code_1,
  current_position: 0,
  rotation_enabled: true,
  rotation_interval_minutes: 60
)

puts "QR Code 1 created:"
puts "  ID: #{qr_code_1.id}"
puts "  Prefix ID: #{qr_code_1.to_param}"
puts "  Name: #{qr_code_1.name}"
puts "  Short URL: #{qr_code_1.short_url}"
puts "  Target URL: #{qr_code_1.target_url}"
puts "  Custom slug: #{shortened_link_1.custom_slug}"

# Create QR Code 2: Without custom slug (auto-generated)
puts "\n=== Creating QR Code 2: Without Custom Slug ==="
shortened_link_2 = ShortenedLink.create!(
  title: "Test QR with Auto Slug",
  target_value: "https://example.com/auto-test",
  schema_type: "url",
  account: account
)

qr_code_2 = QrCode.create!(
  name: "QR Code with Auto-Generated Slug",
  linkable: shortened_link_2,
  account: account,
  created_by: user,
  design_settings: {
    foreground_color: "#000000", 
    background_color: "#FFFFFF",
    dot_style: "rounded",
    corner_style: "rounded"
  }
)

# Create playlist for QR Code 2
playlist_2 = Playlist.create!(
  qr_code: qr_code_2,
  current_position: 0,
  rotation_enabled: true,
  rotation_interval_minutes: 60
)

puts "QR Code 2 created:"
puts "  ID: #{qr_code_2.id}"
puts "  Prefix ID: #{qr_code_2.to_param}"
puts "  Name: #{qr_code_2.name}"
puts "  Short URL: #{qr_code_2.short_url}"
puts "  Target URL: #{qr_code_2.target_url}"
puts "  Auto-generated slug: #{shortened_link_2.short_code}"

puts "\n=== Test Summary ==="
puts "Successfully created 2 QR codes:"
puts "1. QR Code with custom slug 'my-custom-slug' - #{qr_code_1.to_param}"
puts "2. QR Code with auto-generated slug - #{qr_code_2.to_param}"
puts "\nBoth QR codes have playlists and are ready for testing!"
puts "\nYou can access them at:"
puts "1. Custom slug QR: http://localhost:3000/qr_codes/#{qr_code_1.to_param}"
puts "2. Auto slug QR: http://localhost:3000/qr_codes/#{qr_code_2.to_param}"