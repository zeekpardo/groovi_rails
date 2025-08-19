# frozen_string_literal: true

class Accounts::ShortenedLinksController < Accounts::BaseController
  before_action :set_shortened_link, only: [:show, :edit, :update, :destroy]

  # GET /accounts/:account_id/shortened_links
  def index
    @pagy, @shortened_links = pagy(
      current_account.shortened_links
        .includes(:link_clicks, :created_by)
        .recent
    )
  end

  # GET /accounts/:account_id/shortened_links/:id
  def show
    @click_stats = @shortened_link.click_stats
    @recent_clicks = @shortened_link.link_clicks.recent.limit(10)
  end

  # GET /accounts/:account_id/shortened_links/new
  def new
    @shortened_link = current_account.shortened_links.build
  end

  # GET /accounts/:account_id/shortened_links/:id/edit
  def edit
  end

  # POST /accounts/:account_id/shortened_links
  def create
    @shortened_link = current_account.shortened_links.build(shortened_link_params)
    @shortened_link.created_by = current_user

    respond_to do |format|
      if @shortened_link.save
        format.html {
          redirect_to account_shortened_link_path(current_account, @shortened_link),
            notice: t(".created")
        }
        format.json { render :show, status: :created }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @shortened_link.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /accounts/:account_id/shortened_links/:id
  def update
    respond_to do |format|
      if @shortened_link.update(shortened_link_params)
        format.html {
          redirect_to account_shortened_link_path(current_account, @shortened_link),
            notice: t(".updated")
        }
        format.json { render :show, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @shortened_link.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /accounts/:account_id/shortened_links/:id
  def destroy
    @shortened_link.destroy!

    respond_to do |format|
      format.html {
        redirect_to account_shortened_links_path(current_account),
          notice: t(".destroyed"), status: :see_other
      }
      format.json { head :no_content }
    end
  end

  # POST /accounts/:account_id/shortened_links/:id/toggle_active
  def toggle_active
    @shortened_link = current_account.shortened_links.find(params.expect(:id))
    @shortened_link.update!(active: !@shortened_link.active?)

    respond_to do |format|
      format.html {
        redirect_to account_shortened_links_path(current_account),
          notice: t(".toggled")
      }
      format.json { render json: {active: @shortened_link.active?} }
    end
  end

  private

  def set_shortened_link
    @shortened_link = current_account.shortened_links.find(params.expect(:id))
  rescue ActiveRecord::RecordNotFound
    redirect_to account_shortened_links_path(current_account), alert: t("shortened_links.not_found")
  end

  def shortened_link_params
    params.expect(shortened_link: [
      :title, :description, :schema_type, :target_value, :custom_slug,
      :expires_at, :active,
      metadata: [:message, :subject],
      settings: [:utm_source, :utm_medium, :utm_campaign]
    ])
  end
end
