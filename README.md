# `flappi`

## Flexible API builder gem for Rails

Flappi allows Rails APIs to be defined using a simple DSL that avoids repeated and fragmented code and allows the API definition to reflect the request/response structure.
Support is provided for versioning (semantic with the addition of 'flavours') and documentation (using [apiDoc](http://apidocjs.com/)).

Interface documentation is [here](https://sharesight.github.io/flappi/Flappi.html)

## Quickstart with Rails (4-6)

Add to Gemfile:

    gem 'flappi', git: 'git@github.com:sharesight/flappi.git'

Bundle install:

    bundle install

Create your initialization file, e.g. in **'config/initializers/flappi.rb'**
```ruby
Flappi.configure do |conf|
  conf.definition_paths = { 'default' => 'api_definitions' }    # Normally under your controller path
end
```
Create a controller and route, e.g in **'app/controllers/adders_controller'**:
```ruby
class AddersController < ApplicationController
  def show
    Flappi.build_and_respond(self)
  end
end
```
and in **'config/routes.rb'**:

    resource :adder

Flappi (currently) uses the regular Rails routing and controller framework, so this is much as for an ordinary controller.

(If you try the endpoint [http://localhost:3000/adder](http://localhost:3000/adder) now, you should get an error like: *'Endpoint Adders is not defined to API Builder'*)

Now define the endpoint using the Flappi DSL. In **'app/controllers/api_definitions/adders.rb'**:
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

## Adding Fields to APIs
### 1:1 mapping with the model
  Map directly to model attributes like app/controllers/api/v3/api_builder_definitions/shared/currency.rb maps code, symbol and id directly to the app/models/currency.rb objects (and associated enumerables).

### Using the Source Field
In order to add new fields to an API the easiest option is to create an attr_reader on the model you're referencing. For instance app/controllers/api/v3/api_builder_definitions/shared/document.rb has the 4 fields:
[:file_name, :file_size, :created_at, :content_type]
These fields can be whatever you want to use for the api and don't tie to anything in the App itself.

The "source" is where we pull in data for these 4:
[:document_file_name, :document_content_type, :document_file_size, :document_created_at]
These four "sources" are defined in app/models/document.rb as attr_reader methods with the same names as the source.

While its not ideal, if the value you need is not stored ready to go in the database, your attr_reader on the model COULD make a call to a service in order to return the value desired but this isn't really a desirable approach as it shouldn't be the concern of the model. Additional investigation is needed into alternative ways of managing this.

### Using Procs and Lambdas
#### full logic (nested + boolean cast):
field(name: :supported, type: BOOLEAN, doc: '…') { |o| !!o.nominal_country&.ss_support? }

#### re-name an attribute (these examples should be equivalent):
field(:financial_year_end, doc: '…') { |p| p.financial_year_end_s }
field(:financial_year_end, source: :financial_year_end_s, doc: '…')

## Advanced

- [Implementing a POST endpoint](docs/file.POST.html)
- [Nesting structures in a response](docs/file.NEST.html)
- [Sharing fields](docs/file.SHARE.html)
- [Versions](docs/file.VERSIONS.html)

## Contributing

See [CONTRIBUTING](./CONTRIBUTING.md).

## Code of Conduct

See [CODE_OF_CONDUCT](./CODE_OF_CONDUCT.md).
