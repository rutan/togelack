require_relative 'boot'

%w[
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
].each { |railtie| require railtie }

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Togelack
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.time_zone = 'Tokyo'
    config.i18n.default_locale = :ja
    # config.autoload_paths += %W[#{config.root}/lib/commons]
    # config.assets.paths << Emoji.images_path
    # config.assets.precompile << 'emoji/**/*.png'
  end
end
