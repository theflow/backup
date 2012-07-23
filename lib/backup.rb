require 'rubygems'
require 'runt'
require 'date'
require 'backup/configuration'
require 'backup/extensions'
require 'backup/ssh_helpers'
require 'backup/date_parser'
require 'backup/state_recorder'

begin
  require 'right_aws'
  require 'backup/s3_helpers'
  require 'aws-sdk'
rescue LoadError
  # If RightAWS is not installed, no worries, we just
  # wont have access to s3 methods.
end

begin
  require 'madeleine'
rescue LoadError
  # If you don't have madeleine then you just cant use numeric rotation mode
  ::NO_NUMERIC_ROTATION = true
end
