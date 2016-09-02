# flappi
## Flexible API builder gem for Rails

Flappi allows Rails APIs to be defined using a simple DSL that avoids repeated and fragmented code and allows the API definition to reflect the request/response structure.
Support is provided for versioning (semantic with the addition of 'flavours') and documentation (using [apiDoc](http://apidocjs.com/)).

## Quickstart with Rails (4?)

Add to Gemfile:

    gem 'flappi', git: 'git@github.com:sharesight/flappi.git'

Bundle install:

    bundle install

Create your initialization file, e.g. in initializers/flappi.rb

    Flappi.configure do |conf|
      conf.definition_paths = 'api_definitions'     # Normally under your controller path
    end

