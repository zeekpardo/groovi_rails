resources :accounts do
  member do
    patch :switch
  end

  resource :transfer, module: :accounts
  resources :account_users, path: :members
  resources :account_invitations, path: :invitations, module: :accounts do
    member do
      post :resend
    end
  end

  # Scoped shortened links routes
  resources :shortened_links, path: :links, controller: "accounts/shortened_links" do
    member do
      post :toggle_active
    end
  end
end

resources :account_invitations
