Sharing fields
==============

# Introduction

Often, you will have a similar set of fields returned or used by multiple endpoints.

Flappi has no specific mechanism to share fields, but you can easily do this using regular Ruby.

# Example

In [Nesting structures in a response](file.NEST.html) we worked with a `Cheese` type.
We now add a similar `Chocolate` type, which also has `package` and `name` fields:

```ruby
{
  name: 'Milky Way',
  milk: true,
  cocoa_percent: 10,
  package: { weight_grams: 100, price: 2.20 } 
}
```

To save repeating ourselves, we can modify the `Cheese` definition to extract the shared fields:

```ruby
module ApiDefinitions
  module Cheeses

    include Flappi::Definition
    include CommonApi

    def endpoint
      title 'List available cheeses'
       ...
    end

    # Build a record with each result from the table
    # This will call Cheese.where()
    def respond
      build type: Cheese do
        objects :cheeses, doc: 'List of cheeses' do
          field :soft, type: BOOLEAN
          field :cheese_type
      
          common_fields
        end
      end
    end
  end
end
```

and create a module and method for the shared fields

```ruby
module CommonApi
  def common_fields
    field :name
    
    object name: package, type: Package do
      field :weight, source: :weight_grams, type: Integer
      field :price, type: BigDecimal
    end
  end  
end
```

Note that we don't generally need to pass values into the shared method.

We can now use this to implement `Chocolates`:

```ruby
module ApiDefinitions
  module Chocolates

    include Flappi::Definition
    include CommonApi

    def endpoint
      title 'List available chocolates'
       ...
    end

    def respond
      build type: Cheese do
        objects :chocolates, doc: 'List of chocolates' do
          field :milk, type: BOOLEAN
          field :cocoa_percent, type: Float
      
          common_fields
        end
      end
    end
  end
end
```

# Sharing parameters

We can share parameters in the same way as fields:

```ruby
module CommonApi
  def common_params
    param :name, doc: 'The name of the product'
  end
  
  ...
end
```

and use this as:

```ruby
module ApiDefinitions
  module CheesesCreate

    include Flappi::Definition
    include CommonApi

    def endpoint
      title 'Create a cheese'
      ...
      common_params
    end
  
    ...
  end
end
```

and similarly to make an endpoint to create chocolates.
