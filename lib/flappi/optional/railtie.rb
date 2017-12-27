# frozen_string_literal: true

module Flappi
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'flappi/optional/flappi.rake'
    end
  end
end
