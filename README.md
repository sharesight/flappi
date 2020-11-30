# flappi

## Flexible API builder gem for Rails

Flappi allows Rails APIs to be defined using a simple DSL that avoids repeated and fragmented code and allows the API definition to reflect the request/response structure.
Support is provided for versioning (semantic with the addition of 'flavours') and documentation (using [apiDoc](http://apidocjs.com/)).

Interface documentation is [here](https://sharesight.github.io/flappi/Flappi.html)

## Quickstart with Rails (4-6)

Add to Gemfile:

    gem 'flappi', git: 'git@github.com:sharesight/flappi.git'

Bundle install:

    bundle install

Create your initialization file, e.g. in **'initializers/flappi.rb'**
```ruby
Flappi.configure do |conf|
  conf.definition_paths = { 'default' => 'api_definitions' }    # Normally under your controller path
end
```
Create a controller and route, e.g in **'controllers/adders_controller'**:
```ruby
class AddersController < ApplicationController
  def show
    Flappi.build_and_respond(self)
  end
end
```
and in **'config/routes.rb'**:

    resource :adder

Flappi (currently) users the regular Rails routing and controller framework, so this is much as for an ordinary controller.

(If you try the endpoint [http://localhost:3000/adder](http://localhost:3000/adder) now, you should get an error like: *'Endpoint Adders is not defined to API Builder'*)

Now define the endpoint using the Flappi DSL. In **'controllers/api_definitions/adders.rb'**:
```ruby
module ApiDefinitions
  module Adders

    include Flappi::Definition

    def endpoint
      title 'Add numbers'
      http_method 'GET'
      path '/adder'

      # We define two query parameters, 'a' is required
      param :a, type: Integer, optional: false
      param :b, type: Integer

      # IRL, this would probably query your ActiveRecord model, reporting engine
      # or other artefact to get a returned record - we just add two numbers together
      # the result of this is the context for the response
      query do |params|
        {result: params[:a].to_i + (params[:b].try(:to_i) || 0) }
      end
    end

    # Build a record with the one result field
    # Notice how just specifying a name is enough to access the value
    def respond
      build do
        field :result, type: Integer
      end
    end
  end
end
```
Now, if you access: [http://localhost:3000/adder.json?a=4](http://localhost:3000/adder.json?a=4) you should see the result:

    {
    "result": 4
    }

and similarly [http://localhost:3000/adder.json?a=4&b=22](http://localhost:3000/adder.json?a=4&b=22) (etc)

## Advanced

- [Implementing a POST endpoint](file.POST.html)

