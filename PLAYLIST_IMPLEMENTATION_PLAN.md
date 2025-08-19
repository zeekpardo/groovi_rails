# Playlist Feature Implementation Plan

## Overview
Rebuild the playlist feature to match the provided UI design with a music playlist-style interface, modular QR content components, and simplified architecture.

## Standards and Guidelines

### Development Standards
- **Rails Standards**: Follow `rules/1001-rails-controllers.md`, `rules/1002-rails-models.md`, `rules/1003-rails-views.md`
- **JavaScript Standards**: Follow `rules/1004-javascript-stimulus.md` for Stimulus controllers
- **Component Standards**: Use `Components_references/` for UI components (Modals, Buttons, Cards, etc.)
- **Testing Standards**: Follow `rules/1006-testing.md` for comprehensive test coverage

### Internationalization (i18n)
- **Text Externalization**: All user-facing text must use Rails i18n (`t()` helper)
- **Translation Keys**: Follow Rails i18n conventions with nested keys
- **Locale Files**: Add translations to `config/locales/en.yml` and support additional locales
- **Dynamic Content**: Ensure playlist titles, error messages, and UI text are translatable
- **Date/Time**: Use i18n for date and time formatting in playlist displays

### UI Components
- **Buttons**: Use `Components_references/Buttons.html` patterns (`btn btn-primary`, `btn-icon`, etc.)
- **Modals**: Use `Components_references/Modals.html` structure with `modal`, `modal-card` classes
- **Cards**: Use `Components_references/Cards.html` for playlist item containers
- **Forms**: Use `Components_references/Forms.html` patterns with proper validation
- **Pills**: Use `Components_references/Pill.html` for content type indicators

## Current State vs Target State

### Current State
- Playlists have their own names separate from QR codes
- Form-based playlist management interface  
- Separate playlist creation/editing forms
- Playlist items use basic form inputs

### Target State
- Playlists use QR code name (no separate playlist name)
- Music playlist-style management interface
- Modal-based item creation/editing using modular QR content components
- Drag-and-drop reordering with visual feedback
- Inline controls (play, info, delete buttons)

## Implementation Phases

### Phase 1: Refactor QR Content Components for Modularity
**Goal**: Extract QR code content building components to be reusable

#### 1.1 Extract Schema Type Components
- [ ] Create `app/components/qr_content/` directory
- [ ] Extract URL input component (`qr_content/url_component.html.erb`)
- [ ] Extract SMS input component (`qr_content/sms_component.html.erb`) 
- [ ] Extract Email input component (`qr_content/email_component.html.erb`)
- [ ] Extract Phone input component (`qr_content/phone_component.html.erb`)
- [ ] Extract WhatsApp input component (`qr_content/whatsapp_component.html.erb`)
- [ ] Add i18n support to all component labels and placeholders
- [ ] Follow `Components_references/Forms.html` patterns for inputs

#### 1.2 Create Schema Selector Component
- [ ] Extract schema type dropdown (`qr_content/schema_selector_component.html.erb`)
- [ ] Create unified component that renders appropriate input based on schema type
- [ ] Update `schema_switcher_controller.js` to work with modular components

#### 1.3 Create QR Content Builder Component
- [ ] Create main `QrContentBuilderComponent` that combines selector + inputs
- [ ] Make it configurable for different use cases (QR creation, playlist items)
- [ ] Add validation and error handling
- [ ] Test with existing QR code creation/editing

### Phase 2: Simplify Playlist Data Model
**Goal**: Remove playlist complexity, sync with QR code name

#### 2.1 Database Changes
- [ ] Remove `name` field from playlists table
- [ ] Add database constraint: one playlist per QR code
- [ ] Update playlist model to delegate name to QR code
- [ ] Update seeds/fixtures accordingly

#### 2.2 Model Updates
- [ ] Update `Playlist` model to use `qr_code.name` for display
- [ ] Remove playlist name validations
- [ ] Update playlist creation to not require name
- [ ] Add helper method `qr_code_name` to playlist model

#### 2.3 Controller Updates
- [ ] Remove name from playlist params
- [ ] Update playlist creation logic
- [ ] Simplify validation logic

### Phase 3: Build New Playlist Management Interface
**Goal**: Create music playlist-style interface matching the screenshot

#### 3.1 Update Playlist Show Page Layout
- [ ] Replace form-based interface with management interface
- [ ] Add header section with QR code name and "Manage playlist items" subtitle
- [ ] Add "Current URL" section showing active item's target
- [ ] Add control buttons: "Previous" and "Start Over" using `Components_references/Buttons.html`
- [ ] Add "Edit QR Code" button in top right
- [ ] Use Rails i18n for all text (`t('playlists.show.title')`, etc.)
- [ ] Follow `rules/1003-rails-views.md` for responsive design and dark mode support

#### 3.2 Create Playlist Items List Component
- [ ] Build playlist items list with proper styling
- [ ] Add drag handles (6 dots icon) for each item
- [ ] Add content type icons (website, SMS, email, etc.)
- [ ] Add title display with inline edit capability
- [ ] Add URL/content preview
- [ ] Add action buttons: Play (blue circle), Info, Delete (trash)
- [ ] Highlight currently active item with blue border and "Currently Active" badge

#### 3.3 Add Drag-and-Drop Functionality
- [ ] Implement drag-and-drop reordering using Stimulus
- [ ] Add visual feedback during dragging
- [ ] Update playlist item positions on drop
- [ ] Maintain active item state during reordering

### Phase 4: Create Playlist Item Modal
**Goal**: Build modal for creating/editing playlist items using modular QR components

#### 4.1 Create Playlist Item Modal Component
- [ ] Build modal structure using `Components_references/Modals.html` patterns
- [ ] Add title input field with i18n labels
- [ ] Integrate QR Content Builder component
- [ ] Add save/cancel buttons using `Components_references/Buttons.html`
- [ ] Handle create vs edit states
- [ ] Use Rails i18n for modal title and validation messages
- [ ] Follow `rules/1003-rails-views.md` for form validation and accessibility

#### 4.2 Modal Integration
- [ ] Connect "Add Item" button to open modal in create mode
- [ ] Connect "Info" button to open modal in edit mode
- [ ] Handle form submission and validation
- [ ] Update playlist display after save
- [ ] Add proper error handling and user feedback

#### 4.3 Modal JavaScript Controller
- [ ] Create `playlist_item_modal_controller.js` following `rules/1004-javascript-stimulus.md`
- [ ] Handle modal open/close events with proper lifecycle methods
- [ ] Manage form state (create vs edit) using Stimulus values
- [ ] Handle form submission via AJAX with error handling
- [ ] Update playlist items list without page refresh
- [ ] Add proper ES6 syntax and documentation comments

### Phase 5: Implement Playlist Controls
**Goal**: Add functional playlist navigation controls

#### 5.1 Next/Previous Functionality
- [ ] Implement "Start Over" button to reset to first item
- [ ] Add proper state management for current position
- [ ] Update QR code redirect when position changes
- [ ] Add visual feedback for position changes

#### 5.2 Play Button Functionality
- [ ] Make each item's play button activate that specific item
- [ ] Update "Currently Active" indicator
- [ ] Update "Current URL" display
- [ ] Provide immediate feedback on activation

#### 5.3 Current URL Display
- [ ] Show currently active item's target URL
- [ ] Make URL clickable for testing
- [ ] Update display when active item changes
- [ ] Handle empty playlist state

### Phase 6: Enhanced Features
**Goal**: Add polish and advanced functionality

#### 6.1 Visual Enhancements
- [ ] Add content type icons for each schema type
- [ ] Improve drag-and-drop visual feedback
- [ ] Add loading states for async operations
- [ ] Add smooth transitions and animations

#### 6.2 Advanced Functionality
- [ ] Add "Archived" toggle to show/hide archived items
- [ ] Implement item archiving/unarchiving
- [ ] Add keyboard shortcuts for common actions
- [ ] Add item duplication functionality

#### 6.3 Responsive Design
- [ ] Ensure interface works on mobile devices
- [ ] Optimize touch interactions for mobile
- [ ] Test drag-and-drop on touch devices
- [ ] Adjust layout for smaller screens

## Implementation Order

### Week 1: Foundation
1. Phase 1: Refactor QR Content Components (3-4 days)
2. Phase 2: Simplify Data Model (1-2 days)

### Week 2: Core Interface  
3. Phase 3: Build New Interface (4-5 days)

### Week 3: Interactions
4. Phase 4: Create Modal System (3-4 days)
5. Phase 5: Implement Controls (2-3 days)

### Week 4: Polish
6. Phase 6: Enhanced Features (3-5 days)

## Technical Considerations

### Dependencies
- Stimulus.js for interactive components (following `rules/1004-javascript-stimulus.md`)
- `Components_references/Modals.html` for playlist item editing
- Native HTML5 drag-and-drop API (following Rails/Stimulus patterns)
- HeroIcons or similar for content types and action icons
- Rails i18n for all user-facing text

### Testing Strategy
- Unit tests for model changes (following `rules/1006-testing.md`)
- Integration tests for playlist functionality
- JavaScript tests for Stimulus controllers
- Visual regression tests for UI components
- i18n translation coverage tests

### Risk Mitigation
- Implement feature flag for new playlist interface
- Maintain backward compatibility during transition
- Test thoroughly with existing QR codes
- Create migration path for existing playlists

## Success Criteria

### Functional Requirements
- [ ] QR codes can have playlists enabled
- [ ] Playlist items can be created, edited, reordered, and deleted
- [ ] Active playlist item determines QR code redirect
- [ ] Manual navigation works (next, previous, start over)
- [ ] Individual item activation works via play buttons

### User Experience Requirements  
- [ ] Interface matches provided screenshot design
- [ ] Drag-and-drop reordering is smooth and intuitive
- [ ] Modal editing uses familiar QR content building interface
- [ ] All interactions provide immediate feedback
- [ ] Interface is responsive and works on mobile
- [ ] All text is properly internationalized
- [ ] UI components follow established design patterns

### Technical Requirements
- [ ] Modular QR content components are reusable
- [ ] Playlist data model is simplified and efficient
- [ ] No performance regressions
- [ ] Code follows `rules/` conventions (controllers, models, views, JavaScript)
- [ ] Uses `Components_references/` patterns for UI consistency
- [ ] Comprehensive test coverage following `rules/1006-testing.md`
- [ ] Full i18n support with translation keys in `config/locales/`

## Future Enhancements
- Scheduled playlist items with time-based activation
- Playlist templates for common use cases
- Analytics for playlist item usage
- Bulk import/export of playlist items
- Playlist sharing between QR codes