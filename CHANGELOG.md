# CHANGELOG

## 0.10.10 `TBD`
`object` should *not* revert to the enclosing objects data when a name is given. 
 
## 0.10.9 `(2020-02-21)`
Fix issue #43: When an objects source is not found, fields included may be rendered wrongly

## 0.10.8 `(2020-01-13)`
Support array parameters using comma separated or [] syntax
 
## 0.10.7 `(2020-01-06)`
Support the `version` parameter on a `param`, allowing parameters to be supported and documented on a per-version basis

## 0.10.6 `(25/11/2019)`
* Provide a Definition#major_version mathod to use in generating docs for shared definitions between versions

## 0.10.5 `(13/11/2019)`

* Ruby 2.6.5
* When a link is defined at object level, output it in the object rather than at the end of the response
* Validate parameters for permitted / required inside response builder
* Substitute variables into links
* Fix circleci config
* Fix parameter nesting

## 0.10.4 `(07/08/2019)`

* Ruby 2.6.3 support update.

## 0.10.0 `(04/06/2019)`

 * add support for multiple request and response examples and API errors [#36])(https://github.com/sharesight/flappi/pull/36)

## 0.8.1

 * add support for Ruby `2.5.3` [#30])(https://github.com/sharesight/flappi/pull/30)

## 0.5.5

 * Feature: Errors and debugs [#21])(https://github.com/sharesight/flappi/pull/21)

## 0.5.3

 * switch to Ruby `2.5.1` [#20])(https://github.com/sharesight/flappi/pull/20)
