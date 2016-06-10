require 'rails_helper'
require 'bcrypt'

describe User, type: :model do
  before :each do
    @u1 = fixture_factory.fixture_generator.generate_test_user

    @default_user_password = 'randompassword'
  end

  context "when password is not set" do
    before :each do
      @u1.password = nil
      @u1.password_confirmation = nil
    end

    it "is invalid" do
      expect(@u1).not_to be_valid
      expect(@u1.errors.messages[:password]).to include(/cannot be empty/)
    end
  end

  context "when password does not match confirmation" do
    before :each do
      @u1.password = '123'
      @u1.password_confirmation = '456'
    end

    it "is invalid" do
      expect(@u1).not_to be_valid
      expect(@u1.errors.messages[:password]).to include(/did not match the confirmation/)
    end
  end

  context "when password is shorter than 8 characters" do
    before :each do
      @password = 'sth < 8'
      @u1.password = @password
      @u1.password_confirmation = @password
    end

    it "is invalid" do
      expect(@u1).not_to be_valid
      expect(@u1.errors.messages[:password]).to include(/must have length between 8 and 255./)
    end
  end

  context "when password is longer than 255 charaters" do
    before :each do
      @password = 'something longer than 255 like really long like seriously
        longggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg
        ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg
        ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg
        gggggggggg'.squish

      # Sanity check
      expect(@password.length).to be > 255

      @u1.password = @password
      @u1.password_confirmation = @password
    end

    it "is invalid" do
      expect(@u1).not_to be_valid
      expect(@u1.errors.messages[:password]).to include(/must have length between 8 and 255./)
    end
  end

  context "when email is invalid" do
    before :each do
      @invalid_email = 'invalid email'

      @u1.email = @invalid_email
      @u1.password = @default_user_password
      @u1.password_confirmation = @default_user_password
    end

    it "is invalid" do
      expect(@u1).not_to be_valid
      expect(@u1.errors.messages[:email]).to include(/is invalid/)
    end
  end

  it "has encrypted password after save" do
    password = 'asdfadsf'
    @u1.password = password
    @u1.password_confirmation = password

    # Sanity check
    expect(@u1.encrypted_password).to be_empty

    @u1.save

    expect(@u1.encrypted_password).not_to be_empty
  end

  context "when user with given name already exists in the database" do
    before :each do
      @username = 'Test User'
      @u2 = fixture_factory.fixture_generator.create_test_user(
        name: @username, password: @default_user_password, password_confirmation: @default_user_password)

      # Sanity Check
      expect(User.where(name: @username).count).to be > 0

      @u1.name = @username
      @u1.password = @default_user_password
      @u1.password_confirmation = @default_user_password
    end

    it "is invalid" do
      expect(@u1).not_to be_valid
      expect(@u1.errors.messages[:name]).to include(/has already been taken/)
    end
  end

  context "when user with the same email already exists in the database" do
    before :each do
      @email = 'test@test.com'
      @u2 = fixture_factory.fixture_generator.create_test_user(
        email: @email, password: @default_user_password, password_confirmation: @default_user_password)

      # Sanity Check
      expect(User.where(email: @email).count).to be > 0

      @u1.email = @email
      @u1.password = @default_user_password
      @u1.password_confirmation = @default_user_password
    end

    it "is invalid" do
      expect(@u1).not_to be_valid
      expect(@u1.errors.messages[:email]).to include(/has already been taken/)
    end
  end

  context "when required fields are filled" do
    before :each do
      @u1.password = @default_user_password
      @u1.password_confirmation = @default_user_password
    end

    it "is valid" do
      expect(@u1).to be_valid
    end

    it "encrypts the password on create" do
      @u1.save
      expect(@u1.encrypted_password).not_to be_nil
      expect(BCrypt::Password.new(@u1.encrypted_password)).to eq(@default_user_password)
    end
  end

  describe "#update_password!" do
    before :each do
      @u1.password = @default_user_password
      @u1.password_confirmation = @default_user_password
      @u1.save
    end

    context "when password is not set" do
      it "raises an exception" do
        # Sanity check
        expect(@u1.password).to be_nil
        expect(@u1.password_confirmation).to be_nil

        expect{ @u1.update_password! }.to raise_error(User::Errors::CannotUpdatePassword)
      end
    end

    context "when password is set" do
      before :each do
        @new_password = "something different"
        @u1.password = @new_password
        @u1.password_confirmation = @new_password
      end

      it "updates the password" do
        @u1.update_password!
        expect(BCrypt::Password.new(@u1.encrypted_password)).to eq(@new_password)
      end
    end
  end

  describe "#remember_me!" do
    before :each do
      @u1.password = @default_user_password
      @u1.password_confirmation = @default_user_password
      @u1.save
    end

    it "generates a remember digest for the user" do
      # Sanity Check
      expect(@u1.remember_digest).to be_nil

      @u1.remember_me!

      expect(@u1.reload.remember_digest).to be_truthy

      remembered_user_id = @u1.id
      remember_token = @u1.remember_token

      expect(BCrypt::Password.new(@u1.remember_digest))
        .to eq("#{remember_token}_#{remembered_user_id}")
    end
  end

  describe "#forget_me!" do
    before :each do
      @u1.password = @default_user_password
      @u1.password_confirmation = @default_user_password
      @u1.save
      @u1.remember_me!

      # Sanity check
      expect(@u1.remember_digest).to be_truthy
    end

    it "clears the remember digest for the given user" do
      @u1.forget_me!

      expect(@u1.remember_digest).to be_nil
    end
  end
end
