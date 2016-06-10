class FixtureFactory
  attr_accessor :fixtures

  def fixtures
    @fixtures = Fixtures.new
  end

  def fixture_generator
    @fixture_generator ||= FixtureGenerator.new
  end

  def self.wipe_database!
    ActiveRecord::Base.subclasses.each(&:delete_all)
  end

  class Fixtures
    attr_accessor :u1, :u2

    def initialize
      ::FixtureFactory.wipe_database!

      fixture_generator = FixtureGenerator.new

      @u1 = fixture_generator.create_test_user(name: 'Test User 1', email: 'test1@test.com')
      @u2 = fixture_generator.create_test_user(name: 'Test User 2', email: 'test2@test.com')
    end
  end

  class FixtureGenerator
    def generate_test_user(attrs = {})
      default_attrs = {
        name: 'Test User',
        email: 'test@test.com',
        password: '12345678',
        password_confirmation: '12345678'
      }

      User.new(default_attrs.merge(attrs))
    end

    FixtureGenerator.instance_methods.each do |meth|
      next unless meth.to_s.match(/^generate/)
      create_meth_name = meth.to_s.gsub(/^generate/, 'create').to_sym
      define_method(create_meth_name) do |*args|
        instance = send(meth, *args)
        instance.save
        instance
      end
    end
  end
end