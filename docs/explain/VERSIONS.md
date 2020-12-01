Versions
========

# Introduction

Often an API will need to have multiple versions available.  This can allow new functionality to be restricted for e.g. internal use or to ensure backwards compatibility with an older vesion.

Flappi supports a system of [semantic versioning](https://medium.com/the-non-traditional-developer/semantic-versioning-for-dummies-45c7fe04a1f8) and flavouring.

Semantic versioning is a standardised way of labelling ordered releases. An example would be to have versions: 
`V1.0`, `V2.0`, `V2.1`, `V2.1.1`, `V3`, `V3.0.1`

Flavouring allows one release to have multiple flavours, e.g: `V3.0`, `V3.0-internal`, `V3.0-mobile`.

# Providing the version

The version will generally be provided in the request, e.g: `https://api.example.com/v2.1/cheeses.json`
(You could also use a header, or imply it).

Flappi expects that the version text is passed in a `version` parameter. 
In Rails, this can be done through a namespace in the Rails routes, such asL

```ruby
namespace :v2, path: 'V2(.:version)' do
 resources :cheeses
 resources :chocolates
end
```

The configuration (in e.g. **'initializers/flappi.rb'**) will also need to change to match the version:
```ruby
conf.definition_paths = { 
  'default' => 'api_definitions', 
  'v2' => 'api_definitions' 
} 
```

You can use this to direct top level versions to different definition folders.

You now use the URL `http://localhost:3000/v2/cheeses.json` to do a GET on the cheeses endpoint.

If you have an existing versioning system to fit into, you may want to alter this scheme and maybe change the `params[:version]` in a base controller.
 
# Version dependent APIs

You may want to provide a different result dependent on the version.

For instance, we can change the `name` to `product_name` in V3 (this is a breaking change for an API consumer).

To serve `name` in V2 and `product_name` in V3, we can do:
```ruby
  field :name, version: { equals: 'V2.0' } 
  field :product_name, source: :name, version: { matches: 'V3.*' }
```

Notice that we use `source` to map a common source in the backend, and we allow various point versions at V3.

You can specify a version on the `object`, `objects` and `field` methods.

# Version plan

It is possible to optionally define a version plan setting out allowable versions and flavours.

```ruby
module Api
  class FlappiVersionPlan
    extend Flappi::VersionPlan

    # Version numbers are of the form [text][N][,]+[-flavour]

    version 'V2.0.0' do
      flavour :mobile
    end

    version 'v3.0.0' do
      flavour :internal
    end

    flavour ''
  end
end
```

We now allow: `V2.0.0`, `V2.0.0-mobile`, `V3.0.0`, `V3.0.0-internal`. These can be abbreviated by dropping the trailing zero points,
so: `V2`, `V2.0-mobile` etc. are legal versions.

This is then configured into flappi:

```ruby
  Flappi.configure do |conf|
    conf.version_plan = Api::FlappiVersionPlan
    ...
  end  
```
 
# Version restricted endpoints

Having created a version plan (and routed calls to the same major release to a common definition) it is possible to configure 
an endpoint to be only available (and documented) for a particular version.

For instance, to limit an endpoint to internal use, we can do:   

```ruby
  def endpoint
    version equals: 'V3.0-internal'
    ...
  end
```

This makes the endpoint only available with a version of `V3.0-internal`. 

NOTE: limiting access to versions, e.g. by user or OAuth application is not a Flappi concern. 
You would normally do this in a base controller.
 
