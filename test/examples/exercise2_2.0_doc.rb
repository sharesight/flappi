=begin
@api {GET} /examples/exercise2.json Exercise API 2

@apiName Exercise2Versioned
@apiGroup Test_Exercise
@apiVersion 2.0.0-mobile

@apiDescription
  Exercise definition DSL #2 with versioning

@apiUse OAuthHeaders


@apiParam {Float} required
  


@apiParamExample Request Example
    {GET} "/examples/exercise2"


@apiSuccess (200 Success) {String} all


@apiSuccess (200 Success) {String} v2_0_only



@apiSuccessExample {json} Response Example


@apiError (400 Bad Request) {Integer} error
  Internal error code
@apiError (400 Bad Request) {Integer} transaction_id
  Unique identifier for this API transaction.
@apiError (400 Bad Request) {Integer} reason
  Detailed error message what went wrong.

@apiUse OauthErrors
=end
