TEST_LIVE_API = false

require 'rubygems'
require 'test/unit'

unless(TEST_LIVE_API)
  require 'webmock/test_unit'
  include WebMock
end

require_files = []
require_files << File.join(File.dirname(__FILE__), '..', 'lib', 'ruby-tmdb.rb')
require_files.concat Dir[File.join(File.dirname(__FILE__), 'setup', '*.rb')]

require_files.each do |file|
  require File.expand_path(file)
end

#load(File.join('unit', 'test_direct_require.rb'), true)
system('ruby ' + File.expand_path(File.join(File.dirname(__FILE__), 'unit', 'test_direct_require.rb')))