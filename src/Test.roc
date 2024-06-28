module [test, runTest]

import pf.Task exposing [Task]
import Browser
import Driver

# TestBody : Task {} [ErrorMsg Str]
# TestBody a : Task {} a

# TestDefinition := {
#     name : Str,
#     testBody : TestBody,
# }

# test : Str, (Browser -> TestBody) -> TestDefinition
test = \name, testBody ->
    task =
        driver = Driver.create LocalServerWithDefaultPort
        Browser.createBrowserWithCleanup! driver \browser ->
            testBody browser

    {
        name,
        testBody: task |> Task.mapErr handleTestError,
    }

# runTest : TestDefinition -> Task { name : Str, result : Result Str Str } *
runTest = \{ testBody, name } ->
    result = testBody |> Task.result!
    Task.ok {
        name: name,
        result: result,
    }

# handleTestError : or -> Result Str Str
handleTestError = \result ->
    when result is
        WebDriverError msg ->
            ErrorMsg "WebDriverError: $(msg)"

        AssertionError msg ->
            ErrorMsg "AssertionError: $(msg)"

        err ->
            msg = Inspect.toStr err
            ErrorMsg "UnknownError: $(msg)"

