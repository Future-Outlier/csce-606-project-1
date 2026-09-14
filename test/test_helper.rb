require 'simplecov'

SimpleCov.start do
  add_filter '/test/'
  minimum_coverage 80
end

require 'minitest/autorun'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
