Nesting structures in a response
================================

# Introduction

Flappi allows rich responses to be returned that model any kind of backend data.

This uses the `objects`, `object` and `field` methods in `Flappi::Definition` to shape the result data from the query.

# Returning a simple hash object

If our query returns a single object, e.g:

```ruby
{
    name: 'Stilton',
    soft: false,
    type: :blue
}
```

then we can format it into a JSON response simply using the `build/field` methods:

```ruby
build do
  field :name
  field :soft, type: BOOLEAN
  field :type
end
```

# Returning a list of objects

For a query that returns a list of objects, e.g:

```ruby
[
    { name: 'Stilton', soft: false, type: :blue },
    { name: 'Cheddar', soft: false, type: :regular },
]
```

we use the `objects` method to format it:

```ruby
build do
  objects :cheeses do
      field :name
  end  
end
```

This selects the name field, so we get:

```json
{
  "cheeses": 
    [
        { "name": "Stilton" },
        { "name": "Cheddar" }
    ]
}
```

# Nesting an object

You can also nest an object. If we now have a query that returns a nested hash:
```ruby
{
    name: 'Stilton',
    soft: false,
    type: :blue,
    package: { weight_grams: 1000, price: 34.32 } 
}
```

we can use `object` to format the data

```ruby
build do
  objects :cheeses do
    field :name
    field :soft, type: BOOLEAN
    field :type

    object name: package, type: Package do
      field :weight, source: :weight_grams, type: Integer
      field :price, type: BigDecimal
    end
  end  
end
```

which will produce:

```json
{
  "name":"Stilton",
  "soft":false,
  "type":"blue",
  "package":{
    "weight":1000,
    "price":34.32
  }
}
```

Note that:

- We can use `name: :blah` or just `:blah` as the first parameter to specify the field name to `field`, `object` and `objects`
- The `source` parameter lets us change a name from the query result to the generated JSON.
- The `type: Package` names the nested type in the documentation, but doesn't affect the generated JSON (which doesn't have named types).

We can also use `inline_always` to pull a nested object into the parent as inline fields, like this:

```ruby
build do
  objects :cheeses do
    field :name
    field :soft, type: BOOLEAN
    field :type

    object inline_always: true do
      field :weight, source: :weight_grams, type: Integer
      field :price, type: BigDecimal
    end
  end  
end
```

produces

```json
{
  "name":"Stilton",
  "soft":false,
  "type":"blue",
  "weight":1000,
  "price":34.32
}
```

Notice that you _either_ specify a name or `inline_always`.

# Nesting an array

You can easily nest arrays using `objects`. Assuming we now have multiple packages:

```ruby
{
    name: 'Stilton',
    soft: false,
    type: :blue,
    packages: [
      { weight_grams: 1000, price: 34.32 },
      { weight_grams: 250, price: 9.15 }
    ] 
}
```

we can use `objects` like this:

```ruby
build do
  objects :cheeses do
    field :name
    field :soft, type: BOOLEAN
    field :type

    objects name: packages do
      field :weight, source: :weight_grams, type: Integer
      field :price, type: BigDecimal
    end
  end  
end
```

which will produce:

```json
{
  "name":"Stilton",
  "soft":false,
  "type":"blue",
  "packages": [
    { "weight":1000, "price":34.32 },
    { "weight":250, "price":9.15 }
  ]
}
```

# Generating a hash from an array

You may have an input array and want to produce a hash. This can be achieved with the `hashed` option on `objects`.

```ruby
build do
  objects :cheeses, hashed: true do
    hash_key :name
    field :soft
    field :type
  end  
end
```

The `hash_key` extracts the hash key from the data, producing:

```json
{
  "cheeses": { 
      "Stilton": { "soft":false, "type":"blue" },
      "Cheddar": { "soft":false, "type":"regular" },
  }  
}
```
