# Groovi QR & NFC Platform - Implementation Plan

## Overview
This document outlines the implementation plan for building the Groovi QR & NFC platform MVP, a smart QR code management system built on Jumpstart Pro Rails.

## Core Innovation: Schema-Flexible QR Codes
Unlike traditional QR generators, Groovi QR codes can change their entire schema type (URL, SMS, Phone, WhatsApp) after being printed. This is achieved through:
- Static QR codes containing permanent short URLs (e.g., `groovi.link/abc123`)
- Dynamic database-driven redirects that interpret the schema type at runtime
- Instant switching between different content types without reprinting

## MVP Features & Build Order

### Phase 1: URL Shortener with Schema Flexibility (Foundation) 
**Timeline: Week 1-2**

**Note: All features will be fully internationalized with English and Spanish support using Rails I18n.**

#### Core Components:
1. **Database Schema & Migrations**
   ```ruby
   # Migration: db/migrate/xxx_create_shortened_links.rb
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
         t.references :created_by, foreign_key: { to_table: :users }
         
         t.timestamps
         
         t.index :short_code, unique: true
         t.index :custom_slug, unique: true, where: "custom_slug IS NOT NULL"
         t.index [:account_id, :created_at]
         t.index :schema_type
       end
     end
   end
   
   # Migration: db/migrate/xxx_create_link_clicks.rb
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
       end
     end
   end
   ```

2. **Models & Business Logic**
   - `ShortenedLink` model with account scoping (using acts_as_tenant)
   - Schema type validation and target value formatting
   - Automatic short code generation (6-8 alphanumeric characters)
   - Custom slug validation and availability checking
   - Click tracking with real-time analytics
   - Dynamic schema interpretation

3. **Schema Handler Service**
   ```ruby
   class SchemaHandlerService
     def self.build_redirect_url(shortened_link)
       case shortened_link.schema_type
       when 'url'
         shortened_link.target_value
       when 'sms'
         "sms:#{shortened_link.target_value}?body=#{shortened_link.metadata['message']}"
       when 'phone'
         "tel:#{shortened_link.target_value}"
       when 'email'
         "mailto:#{shortened_link.target_value}?subject=#{shortened_link.metadata['subject']}"
       when 'whatsapp'
         "https://wa.me/#{shortened_link.target_value}?text=#{shortened_link.metadata['message']}"
       end
     end
   end
   ```

4. **Controllers & Routes**
   - `Accounts::ShortenedLinksController` - CRUD with schema switching
   - `RedirectController` - Smart redirect handling based on schema type
   - Custom domain routing (e.g., `/:short_code`)
   
5. **UI Components (Jumpstart Pro)**
   ```erb
   <!-- Schema Type Selector -->
   <div class="form-group">
     <%= form.label :schema_type %>
     <%= form.select :schema_type, schema_type_options, {}, 
         { class: "select", data: { action: "change->url-shortener#updateFields" } } %>
   </div>

   <!-- Dynamic form fields based on schema -->
   <div data-url-shortener-target="dynamicFields">
     <!-- URL fields -->
     <div class="form-group" data-schema="url">
       <%= form.label :target_value, "URL" %>
       <%= form.url_field :target_value, class: "form-control", placeholder: "https://example.com" %>
     </div>
     
     <!-- Phone fields -->
     <div class="form-group hidden" data-schema="phone">
       <%= form.label :target_value, "Phone Number" %>
       <%= form.tel_field :target_value, class: "form-control", placeholder: "+1234567890" %>
     </div>
   </div>

   <!-- Copy button -->
   <button class="btn btn-secondary btn-sm" 
           data-controller="clipboard" 
           data-clipboard-text-value="<%= shortened_link.full_url %>">
     Copy Link
   </button>
   ```

### Phase 2: Smart Playlist System (Groovi QR)
**Timeline: Week 3-4**

#### Core Components:
1. **Database Schema**
   ```ruby
   # playlists table (inherits shortened_links behavior)
   - id: bigint
   - account_id: bigint (FK)
   - name: string
   - description: text
   - short_code: string (unique, indexed)
   - playlist_type: string (default: 'sequential')
   - current_position: integer (default: 0)
   - active: boolean (default: true)
   - settings: jsonb
   - created_by: bigint
   - timestamps
   
   # playlist_items table
   - id: bigint
   - playlist_id: bigint (FK)
   - schema_type: string (url, phone, sms, email, whatsapp)
   - title: string
   - target_value: string (URL or contact info)
   - position: integer
   - click_count: integer (default: 0)
   - active: boolean (default: true)
   - metadata: jsonb (schema-specific data)
   - timestamps
   
   # playlist_item_clicks table
   - id: bigint
   - playlist_item_id: bigint (FK)
   - ip_address: inet
   - user_agent: string
   - clicked_at: datetime
   - metadata: jsonb
   ```

2. **Models & Business Logic**
   - `Playlist` model with account scoping
   - `PlaylistItem` model with position-based ordering
   - Support for multiple content types (URL, phone, SMS, email, WhatsApp)
   - Drag-and-drop reordering logic
   - Sequential rotation tracking

3. **Controllers & Routes**
   - `Accounts::PlaylistsController` - Playlist management
   - `Accounts::PlaylistItemsController` - Item CRUD
   - `PlaylistRedirectController` - Handle playlist access
   - API endpoints for drag-and-drop reordering

4. **UI Components (Jumpstart Pro)**
   ```erb
   <!-- Playlist Builder -->
   <div class="card" data-controller="playlist-builder">
     <h3>Playlist Items</h3>
     
     <!-- Add Item Form -->
     <div class="card mb-4">
       <div class="form-group">
         <%= form.select :schema_type, schema_type_options, {}, 
             { class: "select select-sm", data: { action: "change->playlist-builder#updateFields" } } %>
       </div>
       <button class="btn btn-primary btn-sm">Add to Playlist</button>
     </div>
     
     <!-- Draggable Items List -->
     <div data-playlist-builder-target="items" class="space-y-2">
       <% playlist.items.each do |item| %>
         <div class="card card-cta-basic" draggable="true" data-item-id="<%= item.id %>">
           <div class="lg:flex-1">
             <span class="pill pill-sm <%= schema_color(item.schema_type) %>">
               <%= item.schema_type.upcase %>
             </span>
             <h4><%= item.title %></h4>
             <p class="text-gray-600"><%= item.target_value %></p>
           </div>
           <div class="lg:p-0 pt-4">
             <button class="btn btn-secondary btn-sm">Edit</button>
             <button class="btn btn-danger btn-sm" data-turbo-confirm="Are you sure?">Remove</button>
           </div>
         </div>
       <% end %>
     </div>
   </div>
   ```

### Phase 3: QR Code Generator
**Timeline: Week 5-6**

#### Core Concept: Static QR, Dynamic Content
The QR code ALWAYS contains a Groovi short URL (e.g., `https://groovi.link/abc123`). What happens when someone scans it is determined by the database, not the QR code. This enables:
- Changing from a website link to a phone number without reprinting
- Switching between campaigns instantly
- A/B testing different content
- Time-based content changes

#### Core Components:
1. **Database Schema**
   ```ruby
   # qr_codes table
   - id: bigint
   - account_id: bigint (FK)
   - linkable_type: string (polymorphic - ShortenedLink or Playlist)
   - linkable_id: bigint (polymorphic)
   - name: string
   - short_url: string (the permanent URL encoded in QR)
   - design_settings: jsonb (colors, style, logo, etc.)
   - image_data: text (Active Storage reference)
   - download_count: integer (default: 0)
   - scan_count: integer (default: 0)
   - created_by: bigint
   - timestamps
   
   # qr_code_scans table
   - id: bigint
   - qr_code_id: bigint (FK)
   - ip_address: inet
   - user_agent: string
   - location: jsonb
   - scanned_at: datetime
   ```

2. **Integration**
   - qr-code-styling JavaScript library integration
   - Polymorphic association to ShortenedUrls and Playlists
   - Server-side QR code storage (PNG/SVG)
   - Design presets and templates

3. **QR Code Features**
   - Customizable dots style
   - Corner square styles
   - Center image/logo upload
   - Color customization (foreground/background)
   - Transparent background option
   - Download as PNG/SVG
   - Print-ready high-resolution export

4. **UI Components (Jumpstart Pro)**
   ```erb
   <!-- QR Code Designer -->
   <div class="grid md:grid-cols-2 gap-6">
     <!-- Design Controls -->
     <div class="card">
       <h3>QR Code Design</h3>
       
       <!-- Tabs for design options -->
       <div data-controller="tabs">
         <nav class="tab-nav">
           <a href="#" data-tabs-target="tab" data-action="click->tabs#change:prevent">Style</a>
           <a href="#" data-tabs-target="tab" data-action="click->tabs#change:prevent">Colors</a>
           <a href="#" data-tabs-target="tab" data-action="click->tabs#change:prevent">Logo</a>
         </nav>
         
         <!-- Style Panel -->
         <div data-tabs-target="panel">
           <div class="form-group">
             <%= form.label :dot_style %>
             <%= form.select :dot_style, dot_style_options, {}, { class: "select" } %>
           </div>
           <div class="form-group">
             <%= form.label :corner_style %>
             <%= form.select :corner_style, corner_style_options, {}, { class: "select" } %>
           </div>
         </div>
         
         <!-- Colors Panel -->
         <div class="hidden" data-tabs-target="panel">
           <div class="form-group">
             <%= form.label :foreground_color %>
             <%= form.color_field :foreground_color, class: "form-control" %>
           </div>
         </div>
       </div>
     </div>
     
     <!-- Live Preview -->
     <div class="card">
       <h3>Preview</h3>
       <div data-qr-designer-target="preview" class="text-center">
         <!-- QR code renders here via qr-code-styling -->
       </div>
       <div class="mt-4 space-x-2">
         <button class="btn btn-primary" data-action="qr-designer#downloadPNG">Download PNG</button>
         <button class="btn btn-secondary" data-action="qr-designer#downloadSVG">Download SVG</button>
       </div>
     </div>
   </div>
   ```

## Smart Redirect System Architecture

### The Magic: Universal Redirect Controller
```ruby
class RedirectController < ApplicationController
  skip_before_action :authenticate_user! # Public access
  
  def show
    @short_code = params[:short_code]
    @resource = find_resource(@short_code)
    
    return render_404 unless @resource
    
    # Track the click
    ClickTrackerJob.perform_later(@resource, request_details)
    
    # Handle different resource types
    case @resource
    when ShortenedLink
      handle_shortened_link(@resource)
    when Playlist
      handle_playlist(@resource)
    end
  end
  
  private
  
  def handle_shortened_link(link)
    redirect_url = SchemaHandlerService.build_redirect_url(link)
    redirect_to redirect_url, allow_other_host: true
  end
  
  def handle_playlist(playlist)
    # Get current item based on playlist settings
    current_item = playlist.get_current_item
    redirect_url = SchemaHandlerService.build_redirect_url(current_item)
    
    # Advance position for next visit
    playlist.advance_position! if playlist.sequential?
    
    redirect_to redirect_url, allow_other_host: true
  end
  
  def find_resource(short_code)
    ShortenedLink.find_by(short_code: short_code) ||
    Playlist.find_by(short_code: short_code)
  end
end
```

### Campaign Override System (Future Enhancement)
```ruby
class CampaignOverride < ApplicationRecord
  belongs_to :overrideable, polymorphic: true # ShortenedLink or Playlist
  belongs_to :account
  
  scope :active, -> { where(active: true) }
  
  # Allows temporary schema/content changes for campaigns
  # schema_type: string
  # target_value: text
  # starts_at: datetime
  # ends_at: datetime
end
```

## Technical Architecture (Following Jumpstart Pro Standards)

### Coding Standards Overview
All code follows Jumpstart Pro's established patterns:
- **Models**: YARD documentation, positional enums, concerns for shared functionality
- **Controllers**: RESTful conventions, HTTP verb comments, proper status codes
- **Service Objects**: Verb+Noun naming, single responsibility, transaction safety
- **JavaScript**: ES6 syntax, Stimulus controllers with proper lifecycle management
- **Testing**: Minitest with comprehensive coverage
- **UI**: Tailwind CSS, responsive design, dark mode support
- **I18n**: Full internationalization support for English and Spanish locales only

### Internationalization (I18n) Implementation

#### Locale Configuration
```ruby
# config/application.rb (already configured)
config.i18n.available_locales = [:en, :es]
config.i18n.default_locale = :en
config.i18n.fallbacks = [I18n.default_locale]
```

#### Translation File Structure
```
config/locales/
├── en/
│   ├── shortened_links.yml
│   ├── playlists.yml
│   ├── qr_codes.yml
│   ├── navigation.yml
│   └── errors.yml
└── es/
    ├── shortened_links.yml  
    ├── playlists.yml
    ├── qr_codes.yml
    ├── navigation.yml
    └── errors.yml
```

#### Translation Examples
```yaml
# config/locales/en/shortened_links.yml
en:
  shortened_links:
    index:
      title: "Shortened Links"
      new_link: "New Link"
      empty_state: "No shortened links yet"
      empty_state_description: "Create your first shortened link to get started"
    form:
      title: "Title"
      schema_type: "Type"
      target_value: "Target"
      custom_slug: "Custom Slug"
      expires_at: "Expires At"
      schema_types:
        url: "Website URL"
        phone: "Phone Number"
        sms: "Text Message"
        email: "Email Address"
        whatsapp: "WhatsApp"
    show:
      analytics: "Analytics"
      clicks: "Clicks"
      copy_link: "Copy Link"
      edit: "Edit"
      delete: "Delete"
      qr_code: "QR Code"
    notices:
      created: "Shortened link was successfully created."
      updated: "Shortened link was successfully updated."
      deleted: "Shortened link was successfully deleted."
      copied: "Link copied to clipboard!"

# config/locales/es/shortened_links.yml  
es:
  shortened_links:
    index:
      title: "Enlaces Acortados"
      new_link: "Nuevo Enlace"
      empty_state: "No hay enlaces acortados aún"
      empty_state_description: "Crea tu primer enlace acortado para comenzar"
    form:
      title: "Título"
      schema_type: "Tipo"
      target_value: "Destino"
      custom_slug: "Slug Personalizado"
      expires_at: "Caduca El"
      schema_types:
        url: "URL del Sitio Web"
        phone: "Número de Teléfono"
        sms: "Mensaje de Texto"
        email: "Dirección de Email"
        whatsapp: "WhatsApp"
    show:
      analytics: "Análisis"
      clicks: "Clics"
      copy_link: "Copiar Enlace"
      edit: "Editar"
      delete: "Eliminar" 
      qr_code: "Código QR"
    notices:
      created: "El enlace acortado fue creado exitosamente."
      updated: "El enlace acortado fue actualizado exitosamente."
      deleted: "El enlace acortado fue eliminado exitosamente."
      copied: "¡Enlace copiado al portapapeles!"
```

### Backend Structure (Optimized for Jumpstart Pro)
```
app/
├── models/
│   ├── concerns/
│   │   ├── trackable.rb (shared click tracking)
│   │   ├── shortable.rb (short code generation)
│   │   └── schema_switchable.rb (schema type handling)
│   ├── shortened_link.rb (with acts_as_tenant :account)
│   ├── link_click.rb
│   ├── playlist.rb
│   ├── playlist_item.rb
│   ├── playlist_item_click.rb
│   ├── qr_code.rb
│   ├── qr_code_scan.rb
│   └── campaign_override.rb (future)
├── controllers/
│   ├── accounts/ (all use Accounts::BaseController)
│   │   ├── shortened_links_controller.rb
│   │   ├── playlists_controller.rb
│   │   ├── playlist_items_controller.rb
│   │   └── qr_codes_controller.rb
│   ├── redirect_controller.rb (public, no auth)
│   └── api/
│       └── v1/
│           └── analytics_controller.rb
├── services/
│   ├── short_code_generator.rb
│   ├── schema_handler_service.rb
│   ├── click_tracker_service.rb
│   ├── qr_generator_service.rb
│   └── analytics_service.rb
├── policies/ (using Pundit)
│   ├── shortened_link_policy.rb
│   ├── playlist_policy.rb
│   └── qr_code_policy.rb
└── jobs/
    ├── click_analytics_job.rb
    └── geo_location_job.rb
```

### Frontend Structure
```
app/javascript/
├── controllers/
│   ├── url_shortener_controller.js
│   ├── playlist_builder_controller.js
│   ├── qr_designer_controller.js
│   ├── analytics_chart_controller.js
│   └── clipboard_controller.js
├── islands/
│   └── qr_code_styling.js
└── services/
    └── drag_drop_service.js
```

### UI Components (Using Jumpstart Pro Defaults Only)

#### 1. **Forms**
- Use Jumpstart's form helpers and styling
- Standard form controls: `form-control`, `form-group`, `form-hint`
- File uploads with `file-input-group`
- Schema type selector using `select` class
- Validation errors with `error` class

#### 2. **Buttons**
- Primary actions: `btn btn-primary`
- Secondary actions: `btn btn-secondary`
- Danger actions: `btn btn-danger`
- Size variants: `btn-sm`, `btn-lg`
- Loading states with `processing` class

#### 3. **Cards**
- List views: `card` class for shortened links
- Analytics cards: `card card-cta-basic`
- QR code preview: `card card-image`

#### 4. **Navigation**
- Tabs for different sections: `data-controller="tabs"`
- Account navigation using existing `account_navbar`
- Breadcrumbs for nested resources

#### 5. **Modals**
- Delete confirmations: `data-turbo-confirm`
- QR code download options: `modal modal-md`
- Schema editing: `modal modal-lg`

#### 6. **Tables**
- Analytics data: Standard Jumpstart table styling
- Sortable columns using existing helpers
- Responsive tables with horizontal scroll

#### 7. **Alerts & Toasts**
- Success messages: `alert alert-success`
- Error messages: `alert alert-danger`
- Info messages: `alert alert-info`
- Copy notifications: Toast components

#### 8. **Interactive Elements**
- Dropdowns for actions menu
- Tooltips for help text
- Clipboard copy using existing controller
- Drag-and-drop with Stimulus controller

#### 9. **Loading States**
- Skeleton loaders for async content
- Progress indicators for QR generation
- Spinner for redirect tracking

#### 10. **Empty States**
- Use Jumpstart's empty state patterns
- Clear CTAs for first-time users
- Helpful illustrations and messages

### Code Examples Following Jumpstart Pro Standards

#### Model Example
```ruby
# frozen_string_literal: true

# Represents a shortened link with flexible schema types
class ShortenedLink < ApplicationRecord
  include Trackable
  include Shortable
  include SchemaSwitchable
  
  acts_as_tenant :account
  has_prefix_id :link
  
  SCHEMA_TYPES = [:url, :sms, :phone, :email, :whatsapp].freeze
  
  # Validations
  validates :short_code, presence: true, uniqueness: true
  validates :schema_type, inclusion: SCHEMA_TYPES
  validates :target_value, presence: true
  
  # Normalizations
  normalizes :short_code, with: ->(code) { code&.downcase&.strip }
  normalizes :target_value, with: ->(value) { value&.strip }
  
  # Store JSON attributes
  store_accessor :metadata, :message, :subject
  store_accessor :settings, :utm_source, :utm_medium, :utm_campaign
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_schema, ->(type) { where(schema_type: type) }
  
  # Checks if link has expired
  # @return [Boolean] True if the link has expired
  def expired?
    expires_at.present? && expires_at < Time.current
  end
end
```

#### Controller Example (with I18n)
```ruby
class Accounts::ShortenedLinksController < Accounts::BaseController
  before_action :set_shortened_link, only: [:show, :edit, :update, :destroy]
  
  # GET /accounts/:account_id/shortened_links
  def index
    @pagy, @shortened_links = pagy(
      current_account.shortened_links
        .includes(:link_clicks)
        .sort_by_params(params[:sort], sort_direction)
    )
  end
  
  # POST /accounts/:account_id/shortened_links
  def create
    @shortened_link = current_account.shortened_links.new(shortened_link_params)
    
    respond_to do |format|
      if @shortened_link.save
        format.html { redirect_to account_shortened_link_path(current_account, @shortened_link), 
                      notice: t(".created") }
        format.json { render :show, status: :created }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @shortened_link.errors, status: :unprocessable_content }
      end
    end
  end
  
  # PATCH/PUT /accounts/:account_id/shortened_links/1
  def update
    respond_to do |format|
      if @shortened_link.update(shortened_link_params)
        format.html { redirect_to account_shortened_link_path(current_account, @shortened_link), 
                      notice: t(".updated") }
        format.json { render :show, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @shortened_link.errors, status: :unprocessable_content }
      end
    end
  end
  
  # DELETE /accounts/:account_id/shortened_links/1
  def destroy
    @shortened_link.destroy!
    
    respond_to do |format|
      format.html { redirect_to account_shortened_links_path(current_account), 
                    notice: t(".deleted") }
      format.json { head :no_content }
    end
  end
  
  private
  
  def shortened_link_params
    params.expect(shortened_link: [:title, :schema_type, :target_value, :custom_slug, 
                                   :expires_at, metadata: {}])
  end
end
```

#### Service Object Example
```ruby
# frozen_string_literal: true

# Service for generating unique short codes for links
#
# @example
#   service = GenerateShortCodeService.new(custom_slug: "summer-sale")
#   short_code = service.run
#
class GenerateShortCodeService
  MAX_RETRIES = 5
  
  # Initialize the service
  #
  # @param [String, nil] custom_slug Optional custom slug
  def initialize(custom_slug: nil)
    @custom_slug = custom_slug
  end
  
  # Generates a unique short code
  #
  # @return [String] The generated short code
  # @raise [ActiveRecord::RecordNotUnique] If unable to generate unique code
  def run
    return @custom_slug if @custom_slug.present? && available?(@custom_slug)
    
    generate_random_code
  end
  
  private
  
  # Checks if a code is available
  #
  # @param [String] code The code to check
  # @return [Boolean] True if available
  def available?(code)
    !ShortenedLink.exists?(short_code: code) && 
    !Playlist.exists?(short_code: code)
  end
  
  # Generates a random unique code
  #
  # @return [String] The generated code
  def generate_random_code
    retries = 0
    
    loop do
      code = SecureRandom.alphanumeric(6).downcase
      return code if available?(code)
      
      retries += 1
      raise ActiveRecord::RecordNotUnique if retries >= MAX_RETRIES
    end
  end
end
```

#### Stimulus Controller Example
```javascript
// Handles dynamic form fields based on schema type selection
// Example usage:
// <div data-controller="url-shortener">
//   <select data-action="change->url-shortener#updateFields">
//   <div data-url-shortener-target="dynamicFields">

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Define targets for dynamic content
  static targets = ["dynamicFields", "schemaSelect"]
  
  // Define value properties
  static values = {
    currentSchema: { type: String, default: "url" }
  }
  
  // Initialize controller
  connect() {
    this.updateFields()
  }
  
  // Updates form fields based on selected schema type
  updateFields(event) {
    const schemaType = event?.target?.value || this.currentSchemaValue
    
    // Hide all schema-specific fields
    this.dynamicFieldsTarget.querySelectorAll("[data-schema]").forEach(field => {
      field.classList.add("hidden")
    })
    
    // Show relevant fields
    const relevantFields = this.dynamicFieldsTarget.querySelector(`[data-schema="${schemaType}"]`)
    if (relevantFields) {
      relevantFields.classList.remove("hidden")
    }
    
    this.currentSchemaValue = schemaType
  }
}
```

### Key Technical Decisions

1. **Schema-Flexible Architecture**
   - QR codes contain permanent short URLs, not direct content
   - Schema type can be changed without reprinting QR codes
   - Single redirect controller handles all schema types intelligently

2. **Account Scoping with Jumpstart**
   - Leverage Jumpstart's team accounts for multi-tenancy
   - Use `acts_as_tenant :account` on all models
   - Automatic scoping in controllers via `Accounts::BaseController`

3. **Short Code Generation**
   - Service object pattern for code generation
   - Global uniqueness enforced at database level
   - Custom slugs validated for availability
   - Retry logic with exponential backoff for collisions

4. **Smart Redirect Handling**
   - Single public endpoint handles all redirects
   - Schema interpretation at runtime
   - Support for device-specific handling (future)
   - No caching to ensure fresh content delivery

5. **Analytics Architecture**
   - Async processing via ActiveJob (SolidQueue)
   - Real-time click tracking with minimal latency
   - IP geolocation using MaxMind or similar
   - User agent parsing for device/browser detection

6. **QR Code Design Storage**
   - QR designs stored as Active Storage blobs
   - Multiple formats (PNG, SVG) generated on creation
   - Design settings in JSONB for flexibility
   - Template system for quick styling

7. **Performance Optimizations**
   - Database indexes on short_code, clicked_at
   - Counter caches for click_count
   - Eager loading for N+1 prevention
   - PostgreSQL JSONB for flexible metadata

## API Design

### Public Endpoints
```
GET /:short_code          # Redirect shortened URL
GET /p/:playlist_code     # Access playlist
GET /qr/:qr_code         # QR code redirect
```

### Authenticated API
```
# URL Shortener
POST   /api/v1/shortened_urls
GET    /api/v1/shortened_urls/:id/analytics
PATCH  /api/v1/shortened_urls/:id

# Playlists
POST   /api/v1/playlists
PATCH  /api/v1/playlists/:id/reorder
GET    /api/v1/playlists/:id/analytics

# QR Codes
POST   /api/v1/qr_codes/generate
GET    /api/v1/qr_codes/:id/download
```

## Security Considerations

1. **URL Validation**
   - Prevent open redirects
   - Block malicious URLs
   - Validate custom slugs for appropriate content

2. **Rate Limiting**
   - Limit URL creation per account
   - Throttle redirect requests
   - Protect analytics endpoints

3. **Privacy**
   - Anonymous click tracking (no PII storage)
   - GDPR-compliant data handling
   - Optional analytics opt-out

## Testing Strategy (Minitest)

### Model Tests
```ruby
# test/models/shortened_link_test.rb
require "test_helper"

class ShortenedLinkTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:company)
    @shortened_link = shortened_links(:website)
  end
  
  test "should require short_code" do
    link = @account.shortened_links.build(schema_type: :url, target_value: "https://example.com")
    assert_not link.valid?
    assert_includes link.errors[:short_code], "can't be blank"
  end
  
  test "should normalize short_code" do
    link = @account.shortened_links.build(
      short_code: " ABC123 ",
      schema_type: :url,
      target_value: "https://example.com"
    )
    link.valid?
    assert_equal "abc123", link.short_code
  end
  
  test "should detect expiration" do
    assert_not @shortened_link.expired?
    
    @shortened_link.update(expires_at: 1.day.ago)
    assert @shortened_link.expired?
  end
end
```

### Controller Tests
```ruby
# test/controllers/accounts/shortened_links_controller_test.rb
require "test_helper"

class Accounts::ShortenedLinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:company)
    @user = users(:one)
    @shortened_link = shortened_links(:website)
    
    sign_in @user
    switch_account(@account)
  end
  
  test "should get index" do
    get account_shortened_links_url(@account)
    assert_response :success
  end
  
  test "should create shortened_link" do
    assert_difference("ShortenedLink.count") do
      post account_shortened_links_url(@account), params: {
        shortened_link: {
          title: "New Link",
          schema_type: "url",
          target_value: "https://example.com"
        }
      }
    end
    
    assert_redirected_to account_shortened_link_url(@account, ShortenedLink.last)
    assert_equal "Shortened link was successfully created.", flash[:notice]
  end
end
```

### System Tests
```ruby
# test/system/shortened_links_test.rb
require "application_system_test_case"

class ShortenedLinksTest < ApplicationSystemTestCase
  setup do
    @account = accounts(:company)
    @user = users(:one)
    
    sign_in_as(@user)
    switch_account(@account)
  end
  
  test "creating a shortened link with custom slug" do
    visit account_shortened_links_url(@account)
    click_on "New Link"
    
    fill_in "Title", with: "Summer Sale"
    select "URL", from: "Schema type"
    fill_in "URL", with: "https://example.com/sale"
    fill_in "Custom slug", with: "summer2024"
    
    click_on "Create Shortened link"
    
    assert_text "Shortened link was successfully created"
    assert_text "summer2024"
  end
  
  test "switching schema type shows correct fields" do
    visit new_account_shortened_link_url(@account)
    
    # URL fields visible by default
    assert_selector "[data-schema='url']", visible: true
    assert_selector "[data-schema='phone']", visible: false
    
    # Switch to phone
    select "Phone", from: "Schema type"
    
    assert_selector "[data-schema='url']", visible: false
    assert_selector "[data-schema='phone']", visible: true
  end
end
```

### Service Tests
```ruby
# test/services/generate_short_code_service_test.rb
require "test_helper"

class GenerateShortCodeServiceTest < ActiveSupport::TestCase
  test "should use custom slug when available" do
    service = GenerateShortCodeService.new(custom_slug: "custom123")
    assert_equal "custom123", service.run
  end
  
  test "should generate random code when no custom slug" do
    service = GenerateShortCodeService.new
    code = service.run
    
    assert_match /\A[a-z0-9]{6}\z/, code
  end
  
  test "should retry on collision" do
    # Create existing link with known code
    ShortenedLink.create!(
      account: accounts(:company),
      short_code: "abc123",
      schema_type: :url,
      target_value: "https://example.com"
    )
    
    # Mock SecureRandom to return collision then success
    SecureRandom.stub :alphanumeric, "abc123", "xyz789" do
      service = GenerateShortCodeService.new
      assert_equal "xyz789", service.run
    end
  end
end
```

### Performance Considerations
- Use fixtures for fast test data
- Parallel test execution enabled
- Stub external services (geocoding, etc.)
- Use `assert_emails` for email testing
- Mock file uploads with fixture files

## Deployment Considerations

1. **Infrastructure**
   - Redis for caching and rate limiting
   - Background job processing (Sidekiq/SolidQueue)
   - CDN for QR code assets

2. **Monitoring**
   - Error tracking (Honeybadger/Sentry)
   - Performance monitoring (Skylight/Scout)
   - Uptime monitoring for redirect service

## Future Enhancements (Post-MVP)

1. **Scheduled Redirects**
   - Time-based URL switching
   - Recurring schedules
   - Timezone support

2. **Advanced Analytics**
   - Conversion tracking
   - A/B testing
   - Custom event tracking

3. **Team Collaboration**
   - Shared folders
   - Permission levels
   - Activity logs

4. **Integrations**
   - Zapier/Make webhooks
   - Google Analytics
   - Marketing platforms

5. **White Label**
   - Custom domains
   - Branded QR codes
   - API access

## Key Benefits of Schema-Flexible Architecture

### For Users
1. **Never Reprint QR Codes**
   - Change from website to phone number instantly
   - Switch between SMS and WhatsApp without new codes
   - Update content for seasonal campaigns

2. **Ultimate Flexibility**
   - Test different schema types with same QR code
   - A/B test URLs vs direct phone calls
   - Adapt to customer preferences in real-time

3. **Cost Savings**
   - No wasted printed materials
   - No downtime switching campaigns
   - One QR code for multiple use cases

### For Development
1. **Simplified Architecture**
   - Single redirect endpoint handles all types
   - Consistent analytics across all schemas
   - Easy to add new schema types

2. **Maintainability**
   - Schema logic centralized in one service
   - No complex QR code regeneration
   - Clear separation of concerns

## Success Metrics

1. **Performance KPIs**
   - Redirect response time < 50ms
   - QR code generation < 1s
   - Analytics processing < 5s
   - Schema switch time: instant

2. **User Experience**
   - Zero-downtime schema switching
   - Mobile-responsive interface
   - Intuitive schema selector
   - Real-time analytics updates

3. **Business Metrics**
   - Schema switches per account
   - QR codes that never need reprinting
   - Click-through rates by schema type
   - Campaign flexibility score

## UI/UX Design Patterns

### Dashboard Layout (with I18n)
```erb
<% content_for :title, t("dashboard.title") %>

<!-- Main Dashboard -->
<div class="container mx-auto p-4">
  <!-- Stats Cards -->
  <div class="grid md:grid-cols-4 gap-4 mb-6">
    <div class="card">
      <h4 class="text-gray-600"><%= t("dashboard.stats.total_links") %></h4>
      <p class="text-2xl font-bold"><%= current_account.shortened_links.count %></p>
    </div>
    <div class="card">
      <h4 class="text-gray-600"><%= t("dashboard.stats.total_clicks") %></h4>
      <p class="text-2xl font-bold"><%= number_with_delimiter(total_clicks) %></p>
    </div>
    <div class="card">
      <h4 class="text-gray-600"><%= t("dashboard.stats.total_playlists") %></h4>
      <p class="text-2xl font-bold"><%= current_account.playlists.count %></p>
    </div>
    <div class="card">
      <h4 class="text-gray-600"><%= t("dashboard.stats.total_qr_codes") %></h4>
      <p class="text-2xl font-bold"><%= current_account.qr_codes.count %></p>
    </div>
  </div>

  <!-- Quick Actions -->
  <div class="card card-cta-basic mb-6">
    <div class="lg:flex-1">
      <h3><%= t("dashboard.quick_actions.title") %></h3>
      <p><%= t("dashboard.quick_actions.description") %></p>
    </div>
    <div class="lg:p-0 pt-4 space-x-2">
      <%= link_to t("dashboard.quick_actions.new_link"), new_account_shortened_link_path(current_account), class: "btn btn-primary" %>
      <%= link_to t("dashboard.quick_actions.new_playlist"), new_account_playlist_path(current_account), class: "btn btn-secondary" %>
    </div>
  </div>

  <!-- Recent Activity Table -->
  <div class="card">
    <div class="flex justify-between items-center mb-4">
      <h3><%= t("dashboard.recent_links.title") %></h3>
      <%= link_to t("dashboard.recent_links.view_all"), account_shortened_links_path(current_account), class: "btn btn-secondary btn-sm" %>
    </div>
    
    <% if recent_links.any? %>
      <table class="table">
        <thead>
          <tr>
            <th><%= t("dashboard.recent_links.columns.name") %></th>
            <th><%= t("dashboard.recent_links.columns.type") %></th>
            <th><%= t("dashboard.recent_links.columns.clicks") %></th>
            <th><%= t("dashboard.recent_links.columns.created") %></th>
            <th><%= t("dashboard.recent_links.columns.actions") %></th>
          </tr>
        </thead>
        <tbody>
          <% recent_links.each do |link| %>
            <tr>
              <td>
                <div>
                  <strong><%= link.title %></strong>
                  <div class="text-sm text-gray-500"><%= formatted_short_url(link) %></div>
                </div>
              </td>
              <td>
                <span class="pill pill-sm <%= schema_color(link.schema_type) %>">
                  <%= t("shortened_links.form.schema_types.#{link.schema_type}") %>
                </span>
              </td>
              <td><%= number_with_delimiter(link.click_count) %></td>
              <td><%= time_ago_in_words(link.created_at) %> <%= t("common.ago") %></td>
              <td>
                <div class="flex space-x-2">
                  <%= link_to t("common.edit"), edit_account_shortened_link_path(current_account, link), class: "btn btn-secondary btn-sm" %>
                  <%= button_to t("common.delete"), account_shortened_link_path(current_account, link), 
                      method: :delete, 
                      data: { turbo_confirm: t("common.confirm_delete") },
                      class: "btn btn-danger btn-sm" %>
                </div>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    <% else %>
      <div class="text-center py-8">
        <div class="text-6xl text-gray-300 mb-4">🔗</div>
        <h3><%= t("dashboard.recent_links.empty_state.title") %></h3>
        <p class="text-gray-600 mb-4"><%= t("dashboard.recent_links.empty_state.description") %></p>
        <%= link_to t("dashboard.recent_links.empty_state.action"), new_account_shortened_link_path(current_account), class: "btn btn-primary" %>
      </div>
    <% end %>
  </div>
</div>

<!-- Translation files needed: -->
<!-- config/locales/en/dashboard.yml -->
<!-- config/locales/es/dashboard.yml -->
```

#### Additional I18n Configuration Files Needed
```yaml
# config/locales/en/dashboard.yml
en:
  dashboard:
    title: "Dashboard"
    stats:
      total_links: "Total Links"
      total_clicks: "Total Clicks"
      total_playlists: "Total Playlists"
      total_qr_codes: "Total QR Codes"
    quick_actions:
      title: "Create New"
      description: "Start by creating a shortened link or playlist"
      new_link: "New Link"
      new_playlist: "New Playlist"
    recent_links:
      title: "Recent Links"
      view_all: "View All"
      columns:
        name: "Name"
        type: "Type"
        clicks: "Clicks"
        created: "Created"
        actions: "Actions"
      empty_state:
        title: "No links yet"
        description: "Create your first shortened link to get started"
        action: "Create Link"

# config/locales/es/dashboard.yml
es:
  dashboard:
    title: "Panel de Control"
    stats:
      total_links: "Total Enlaces"
      total_clicks: "Total Clics"
      total_playlists: "Total Listas"
      total_qr_codes: "Total Códigos QR"
    quick_actions:
      title: "Crear Nuevo"
      description: "Comienza creando un enlace acortado o lista de reproducción"
      new_link: "Nuevo Enlace"
      new_playlist: "Nueva Lista"
    recent_links:
      title: "Enlaces Recientes"
      view_all: "Ver Todos"
      columns:
        name: "Nombre"
        type: "Tipo"
        clicks: "Clics"
        created: "Creado"
        actions: "Acciones"
      empty_state:
        title: "No hay enlaces aún"
        description: "Crea tu primer enlace acortado para comenzar"
        action: "Crear Enlace"

# config/locales/en/common.yml
en:
  common:
    edit: "Edit"
    delete: "Delete"
    save: "Save"
    cancel: "Cancel"
    ago: "ago"
    confirm_delete: "Are you sure you want to delete this item?"

# config/locales/es/common.yml  
es:
  common:
    edit: "Editar"
    delete: "Eliminar"
    save: "Guardar"
    cancel: "Cancelar"
    ago: "hace"
    confirm_delete: "¿Estás seguro de que quieres eliminar este elemento?"
```

### Mobile-First Considerations
- Use responsive grid classes (`grid md:grid-cols-*`)
- Tabs convert to select on mobile (`sm:hidden`)
- Cards stack vertically on small screens
- Tables scroll horizontally with `overflow-x-auto`
- Touch-friendly button sizes (`btn-lg` on mobile)

### Accessibility
- Proper form labels and ARIA attributes
- Keyboard navigation support
- Screen reader friendly empty states
- High contrast mode support
- Focus indicators on interactive elements

## MVP Timeline Summary

- **Week 1-2**: URL Shortener with schema flexibility
- **Week 3-4**: Smart Playlist System
- **Week 5-6**: QR Code Generator with qr-code-styling
- **Total MVP**: 6 weeks

This implementation plan provides a clear roadmap for building the Groovi QR & NFC platform MVP with its revolutionary schema-flexible QR codes, using only Jumpstart Pro's default UI components for consistency and faster development.