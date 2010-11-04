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