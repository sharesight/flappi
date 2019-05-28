=begin
@api {PATCH} /examples/exercise7.json Exercise API 7

@apiName Exercise7Param
@apiGroup Test_Exercise
@apiVersion 0.0.0

@apiDescription
  Exercise definition DSL #7 - parameters including nested

@apiUse OAuthHeaders


@apiParam {Integer} [id]
  Id to update

@apiParam {String} [obj/nested]
  A nested parameter


@apiParamExample Request Example
{PATCH} "/api/examples/exercise7


@apiSuccess (200 Success) {String} obj


@apiSuccess (200 Success) {String} obj.nested



@apiSuccessExample {json} Response Example
{
  obj: {
    nested: 'blah'
  }
}


@apiError (400 Bad Request) {Integer} error
  Internal error code
@apiError (400 Bad Request) {Integer} transaction_id
  Unique identifier for this API transaction.
@apiError (400 Bad Request) {Integer} reason
  Detailed error message what went wrong.

@apiUse OauthErrors

=end
