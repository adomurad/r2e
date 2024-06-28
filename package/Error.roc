module [
    FindResult,
    R2EError,
    toWebDriverError,
]

import pf.Http

# ----------------------------------------------------------------

FindResult a : [Found a, NotFound]

R2EError : [AssertionError Str, WebDriverError Str, Custom Str]

# toWebDriverError : [HttpError Http.Error, JsonParsingError *] -> Roc2EndError
toWebDriverError = \err ->
    when err is
        HttpErr e ->
            WebDriverError (Http.errorToString e)

        JsonParsingError _ ->
            WebDriverError "json decoding error"

