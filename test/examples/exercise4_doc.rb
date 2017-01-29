=begin
@api {GET} /examples/exercise1.json Exercise API 3

@apiName Exercise3
@apiGroup Test_Exercise
@apiVersion 0.0.0

@apiDescription
  Exercise definition DSL #3

@apiUse OAuthHeaders



@apiParamExample Request Example
    {GET} "/api/examples/exercise3"


@apiSuccess (200 Success) {String} a_not
First field (not)

@apiSuccess (200 Success) {String} b_how
Second field (how)


@apiSuccessExample {json} Response Example
{
}


@apiError (400 Bad Request) {Integer} error
  Internal error code
@apiError (400 Bad Request) {Integer} transaction_id
  Unique identifier for this API transaction.
@apiError (400 Bad Request) {Integer} reason
  Detailed error message what went wrong.

@apiUse OauthErrors
=end
