require 'rails_helper'

describe SessionsController, :type => :controller do
  def fxt_gen
    fixture_factory.fixture_generator
  end

  before :each do
    @fxt = fixture_factory.fixtures
    @default_user_params = {
        name: 'Test User',
        email: 'test@test.com',
        password: 'testtest',
        password_confirmation: 'testtest'
      }
  end

  describe "POST sessions#user_sign_in" do
    before :each do
      @user = fxt_gen.create_test_user(@default_user_params)
    end

    context "when attempting to sign in with invalid credentials" do
      before :each do
        @params = {
            email: @user.email,
            password: 'invalid password'
          }
      end

      it "responds with status 401 and proper error message" do
        post :user_sign_in, session: @params, format: 'json'

        expect(response).to have_http_status(401)

        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_response[:error][:message]).to match(/Invalid email\/password combination/)
      end
    end

    context "when attempting to sign in with valid credentials" do
      before :each do
        @params = {
          email: @user.email,
          password: @default_user_params[:password]
        }
      end

      it "responds with status 201 and remember token" do
        post :user_sign_in, session: @params, format: 'json'

        expect(response).to have_http_status(201)

        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_response).to have_key(:user_id)
        expect(parsed_response).to have_key(:remember_token)
        expect(parsed_response[:remember_token]).to be_truthy
      end
    end
  end

  describe "DELETE sessions#user_sign_out" do
    before :each do
      @user = fxt_gen.create_test_user(@default_user_params)
      subject.sign_in(@user, remember_user: true)

      # Sanity Check
      expect(subject).to be_user_signed_in
      expect(session[:user_id]).to eq(@user.id)
      expect(cookies.signed[:user_id]).to eq(@user.id)
      expect(cookies[:remember_token]).to be_truthy
    end

    it "signs out given user" do
      delete :user_sign_out, format: 'json'

      expect(session[:user_id]).to be_nil
      expect(cookies[:user_id]).to be_nil
      expect(cookies[:remember_token]).to be_nil
    end
  end
end