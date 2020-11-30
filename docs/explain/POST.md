Implementing a POST endpoint
=============================

# Setup

This assumes you have a Rails app with a model `Cheese` defined, mapping to a database (e.g. SQLite). 
It should have one required column, `name`.

You should also have [curl](https://curl.se/) installed.

# Implementation

Add a route to your **'config/routes.rb'** :
```
  resources :cheeses
```

Create a controller in **'controllers/cheeses_controller'**:
```ruby
class CheesesController < ApplicationController

  skip_before_action :verify_authenticity_token

  def create
    Flappi.build_and_respond(self, :create)
  end
end
```

Note that we don't need an authenticity token as this is an API (you may do this in a superclass, something like: `ApiController`)

The second parameter to `Flappi.build_and_respond` sets the action - this causes a definition `Cheeses` + `Create` => `CheesesCreate` to be used.

Now, create your `CheesesCreate` definition class in **'app/controllers/api_definitions/cheeses_create.rb'**.

```ruby
module ApiDefinitions
  module CheesesCreate

    include Flappi::Definition

    def endpoint
      title 'Create a cheeses'
      http_method 'POST'
      path '/cheeses'
      check_params true
      param :name, doc: 'The name of the cheese'
    end

    # Post data to the model's create! method 
    def respond
      build type: Cheese, as: :create! do
        field :name, doc: 'The name of the cheese'
      end
    end
  end
end
```

This implements a POST method `/cheeses`. It takes one parameter `name` which will be written into the created record.
Setting `check_params true` is needed for Rails permitted parameters.
The `build` statement results in a call to the `Cheese.create!` method with a hash of the params, creating a record.
The body of `build` defines the response, returning a hash with the `name`.

# Testing

Running the command:

`curl -X POST -d name=Gruyere 'http://localhost:3000/cheeses.json'`

should now create an entry in the database.

