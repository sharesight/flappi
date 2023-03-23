# CHANGELOG

## 0.11.0 `(2023-03-24)`

 * Add support Ruby 3.0 [#59](https://github.com/sharesight/flappi/pull/59)
 * Delete CircleCI config [#57](https://github.com/sharesight/flappi/pull/57)
 * Add Slack notification for 'tests' and 'linters' Github Actions workflows [#56](https://github.com/sharesight/flappi/pull/56)
 * Run tests and Rubocop with Github Actions [#55](https://github.com/sharesight/flappi/pull/55)
 * Address CircleCI Ruby image deprecation [#54](https://github.com/sharesight/flappi/pull/54)
 * Skip file generation if `#skip_docs` method present [#53](https://github.com/sharesight/flappi/pull/53)
 * Raise on deprecation warnings [#52](https://github.com/sharesight/flappi/pull/52)
 * Remove support for Ruby 2.6 [#51](https://github.com/sharesight/flappi/pull/51)
 * Update links in README.md [#50](https://github.com/sharesight/flappi/pull/50)

## 0.10.12 `(2021-07-21)`

* Fix the Ruby warning about re-initializing the constant [#49])(https://github.com/sharesight/flappi/pull/49)

## 0.10.11 `(2021-07-01)`

* Support Ruby 2.7.x [#48])(https://github.com/sharesight/flappi/pull/48)

## 0.10.10 `(2020-02-21)`

 * Log errors [#46])(https://github.com/sharesight/flappi/pull/46)

## 0.10.9 `(2020-02-21)`

 * Fix issue #43: When an objects source is not found, fields included may be rendered wrongly

## 0.10.8 `(2020-01-13)`

 * Support array parameters using comma separated or [] syntax

## 0.10.7 `(2020-01-06)`

 * Support the `version` parameter on a `param`, allowing parameters to be supported and documented on a per-version basis

## 0.10.6 `(2019-11-25)`

 * Provide a Definition#major_version mathod to use in generating docs for shared definitions between versions

## 0.10.5 `(2019-11-13)`

 * Ruby 2.6.5
 * When a link is defined at object level, output it in the object rather than at the end of the response
 * Validate parameters for permitted / required inside response builder
 * Substitute variables into links
 * Fix circleci config
 * Fix parameter nesting

## 0.10.4 `(2019-08-07)`

* Ruby 2.6.3 support update.

## 0.10.0 `(2019-06-04)`

 * add support for multiple request and response examples and API errors [#36])(https://github.com/sharesight/flappi/pull/36)

## 0.8.1

 * add support for Ruby `2.5.3` [#30])(https://github.com/sharesight/flappi/pull/30)

## 0.5.5

 * Feature: Errors and debugs [#21])(https://github.com/sharesight/flappi/pull/21)

## 0.5.3

 * switch to Ruby `2.5.1` [#20])(https://github.com/sharesight/flappi/pull/20)
