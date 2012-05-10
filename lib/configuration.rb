# Load application defaults and custom configurations.
# TODO: Move to some sort of initializer.
environment = ENV['RACK_ENV'] || 'development'
application_defaults = YAML.load(ERB.new(File.read("./config/application_defaults.yml")).result)
configuration = YAML.load(ERB.new(File.read("./config/application.yml")).result)
CONFIG = ActiveSupport::HashWithIndifferentAccess.new application_defaults.merge(configuration)

