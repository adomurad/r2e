## `Test` module contains function to create and run tests.
## This module is used in the _"e2e framework mode"_.
module [test, customTest, runTest, printResults, runAllTests, getResultCode]

import pf.Task exposing [Task]
import pf.Stdout
import Browser
import Driver
import Internal exposing [Browser, Driver]

TestBodySafe : Task {} [ErrorMsg Str]

TestBody a : Task {} [AssertionError Str, Custom Str, WebDriverError Str]a where a implements Inspect

TestDefinition := {
    name : Str,
    testBody : TestBodySafe,
}

## Create a r2e test with basic `Driver` configuration
## - targeting "http://localhost:9515"
##
## ```
## myTest = test "open roc-lang.org website" \browser ->
##     # open roc-lang.org
##     browser |> Browser.navigateTo! "http://roc-lang.org"
## ```
test : Str, (Browser -> TestBody a) -> TestDefinition where a implements Inspect
test = \name, testBody ->
    driver = Driver.create LocalServerWithDefaultPort
    (customTest driver) name testBody

## Create a r2e test with custom `Driver` configuration.
##
## ```
## driver = Driver.create (RemoteServer "http://my.webdriver.hub.com:9515")
## test = customTest driver
##
## myTest = test "open roc-lang.org website" \browser ->
##     # open roc-lang.org
##     browser |> Browser.navigateTo! "http://roc-lang.org"
## ```
customTest : Driver -> (Str, (Internal.Browser -> TestBody a) -> TestDefinition) where a implements Inspect
customTest = \driver ->
    testFunc : Str, (Browser -> TestBody a) -> TestDefinition where a implements Inspect
    testFunc = \name, testBody ->
        task =
            Browser.createBrowserWithCleanup driver \browser ->
                testBody browser

        @TestDefinition {
            name,
            testBody: task |> Task.mapErr handleTestError,
        }

    testFunc

## Run a single r2e test.
##
## ```
## myTest = test "open roc-lang.org website" \browser ->
##     # open roc-lang.org
##     browser |> Browser.navigateTo! "http://roc-lang.org"
##
## main =
##     testResult = Test.runTest! myTest
##     Test.printResults! [testResult]
## ```
runTest : TestDefinition -> Task.Task { name : Str, result : Result {} [ErrorMsg Str] } *
runTest = \@TestDefinition { testBody, name } ->
    result = testBody |> Task.result!
    Task.ok {
        name: name,
        result: result,
    }

# handleTestError : [AssertionError Str, WebDriverError Str]a -> [ErrorMsg Str] where a implements Inspect
handleTestError = \result ->
    when result is
        WebDriverError msg ->
            ErrorMsg "WebDriverError: $(msg)"

        AssertionError msg ->
            ErrorMsg "AssertionError: $(msg)"

        err ->
            msg = Inspect.toStr err
            ErrorMsg "UnknownError: $(msg)"

color = {
    gray: "\u(001b)[4;90m",
    red: "\u(001b)[91m",
    green: "\u(001b)[92m",
    end: "\u(001b)[0m",
}

## Print r2e test results to Stdout.
##
## ```
## myTest = test "open roc-lang.org website" \browser ->
##     # open roc-lang.org
##     browser |> Browser.navigateTo! "http://roc-lang.org"
##
## main =
##     testResults = Test.runAllTests! [myTest]
##     Test.printResults! testResults
## ```
printResults : List { name : Str, result : Result {} [ErrorMsg Str] } -> Task.Task {} _
printResults = \results ->
    Stdout.line! "Results:"
    tasks = List.mapWithIndex results \res, i ->
        index = i |> Num.toStr
        when res.result is
            Ok {} -> Stdout.line "$(color.gray)Test $(index):$(color.end) \"$(res.name)\": $(color.green)OK$(color.end)"
            Err (ErrorMsg e) -> Stdout.line "$(color.gray)Test $(index):$(color.end) \"$(res.name)\": $(color.red)$(e)$(color.end)"
    Task.seq (tasks |> List.reverse) |> Task.map! \_ -> {}
    # empty line
    Stdout.line! ""

    totalCount = results |> List.len
    errorCount = results |> List.countIf \{ result } -> result |> Result.isErr
    successCount = totalCount - errorCount
    totalCountStr = totalCount |> Num.toStr
    errorCountStr = errorCount |> Num.toStr
    successCountStr = successCount |> Num.toStr

    msg = "Total:\t$(totalCountStr)\nPass:\t$(successCountStr)\nFail:\t$(errorCountStr)"
    if errorCount > 0 then
        Stdout.line "$(color.red)$(msg)$(color.end)"
    else
        Stdout.line "$(color.green)$(msg)$(color.end)"

## Run a list of r2e tests.
##
## ```
## myTest = test "open roc-lang.org website" \browser ->
##     # open roc-lang.org
##     browser |> Browser.navigateTo! "http://roc-lang.org"
##
## main =
##     testResults = Test.runAllTests! [myTest]
##     Test.printResults! testResults
## ```
runAllTests : List TestDefinition -> Task.Task (List { name : Str, result : Result {} [ErrorMsg Str] }) *
runAllTests = \tasks ->
    # Task.seq and Task.forEach do not work for this - compiler bug
    (_, allResults) = Task.loop! (tasks, []) \(remainingTests, results) ->
        when remainingTests is
            [] -> Task.ok (Done ([], results))
            [task, .. as rest] ->
                result = task |> Test.runTest!
                newResults = List.append results result
                Task.ok (Step (rest, newResults))

    Task.ok allResults

## Get the result code.
##
## You can return this code from the `main` function
## to indicate to the running CI process if the
## test run was a success or a failure.
##
## ```
## main =
##     Stdout.line! "Starting test suite!"
##
##     tasks = [test1, test2]
##
##     # run all tests
##     results = Test.runAllTests! tasks
##     # print results to Stdout
##     Test.printResults! results
##     # return an exit code for the cli
##     results |> Test.getResultCode
## ```
getResultCode : List { name : Str, result : Result {} [ErrorMsg Str] } -> Task.Task {} [Exit I32 Str]
getResultCode = \results ->
    anyFailures =
        results
        |> List.any \{ result } -> result |> Result.isErr

    if anyFailures then
        Task.err (Exit 1 "Test run failed")
    else
        Task.ok {}
