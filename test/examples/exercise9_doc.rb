=begin
@api {GET} /examples/exercise1.json Exercise API 9

@apiName Exercise9
@apiGroup Test_Exercise
@apiVersion 0.0.0

@apiDescription
  Exercise definition DSL #9

@apiUse OAuthHeaders


@apiParam {Integer} [extra]
  An extra query parameter

@apiParam {Integer} [defaulted=123]
  Parameter with default


@apiParamExample Request Example
{GET} "/api/examples/exercise?extra=100"


@apiSuccess (200 Success) {String} extra


@apiSuccess (200 Success) {String} defaulted


@apiSuccess (200 Success) {String[]} data


@apiSuccess (200 Success) {String} data.n


@apiSuccess (200 Success) {String} data.name


@apiSuccess (200 Success) {String} data.alt_name



@apiSuccessExample {json} Special Response Example
{
  extra_plus_1: 101,
  rows: [
    { n: 1, name: 'one', alt_name: 'one' },
    { n: 2, name: 'two', alt_name: 'one' }
  ]
}


@apiError (400 Bad Request) {Integer} error
  Internal error code
@apiError (400 Bad Request) {Integer} transaction_id
  Unique identifier for this API transaction.
@apiError (400 Bad Request) {Integer} reason
  Detailed error message what went wrong.

@apiUse OauthErrors
=end
