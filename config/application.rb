require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module EasyNutri
  class Application < Rails::Application
    config.load_defaults 7.1
    config.autoload_lib(ignore: %w[assets tasks])

    config.generators.system_tests = nil
    
    config.paths.add "features", glob: "**/*.{feature,rb}"
  end
end
