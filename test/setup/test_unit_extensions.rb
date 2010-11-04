module Test::Unit
  # Used to fix a minor minitest/unit incompatibility in flexmock
  AssertionFailedError = Class.new(StandardError)
  
  class TestCase
   
    def self.test(name, &block)
      test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
      defined = instance_method(test_name) rescue false
      raise "#{test_name} is already defined in #{self}" if defined
      if block_given?
        define_method(test_name, &block)
      else
        define_method(test_name) do
          flunk "No implementation provided for #{name}"
        end
      end
    end

  end
end

module Test::Unit::Assertions
  
  def assert_difference(measure, difference = 1)
    before = eval(measure)
    yield
    after = eval(measure)
    message = "Expected '#{measure}' to be: #{before + difference} but was: #{after}\n"
    assert_block(message) do
      after == (before + difference)
    end
  end
  
end