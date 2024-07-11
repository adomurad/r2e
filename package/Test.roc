## `Test` module contains function to create and run tests.
## This module is used in the _"e2e framework mode"_.
module [test, runAllTests, TestRunnerOptions]

import pf.Task exposing [Task]
import pf.Stdout
import pf.Utc
import Browser
import Driver
import Internal exposing [Browser, Driver]
import InternalReporting exposing [TestRunResult]

TestRunOptions : {
    screenshotOnFail : Bool,
}

TestBodyRunFunction : Driver, TestRunOptions -> Task {} [ErrorMsg Str, ErrorMsgWithScreenshot Str Str]

TestBody a : Task {} [AssertionError Str, Custom Str, WebDriverError Str]a where a implements Inspect

TestDefinition := {
    name : Str,
    testCallback : TestBodyRunFunction,
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
test = \name, testCallback ->
    task = \driver, { screenshotOnFail } ->
        browser = driver |> Browser.createBrowser!
        result = testCallback browser |> Task.result!

        screenshot = screenshotOnFail |> takeConditionalScreenshot! browser
        browser |> Browser.close!

        Task.ok { result, screenshot }

    taskSafe = \driver, options ->
        output = task driver options |> Task.result!
        when output is
            # test run success
            Ok { result: Ok _, screenshot: _ } -> Task.ok {}
            # test run failed
            Ok { result: Err err, screenshot: NoScreenshot } ->
                Task.err (err |> errorToStr |> ErrorMsg)

            # test run failed with screenshot
            Ok { result: Err err, screenshot: ScreenshotBase64 screen } ->
                Task.err (err |> errorToStr |> ErrorMsgWithScreenshot screen)

            # should not happen - compiler
            Ok { result: Err err, screenshot: _ } ->
                Task.err (err |> errorToStr |> ErrorMsg)

            # test run failed outside of test body e.g. could not create browser
            Err err -> Task.err (err |> errorToStr |> ErrorMsg)

    @TestDefinition {
        name,
        testCallback: \driver, options -> taskSafe driver options,
    }

takeConditionalScreenshot : Bool, Internal.Browser -> Task [ScreenshotBase64 Str, NoScreenshot] _
takeConditionalScreenshot = \shouldTakeScreenshot, browser ->
    if shouldTakeScreenshot then
        screenshot =
            browser
                |> Browser.getScreenshotBase64
                |> Task.result!
                |> Result.withDefault ""
        Task.ok (ScreenshotBase64 screenshot)
    else
        Task.ok NoScreenshot

runTest : TestDefinition, Driver, TestRunOptions -> Task.Task TestRunResult *
runTest = \@TestDefinition { testCallback, name }, driver, options ->
    startTime = Utc.now!
    result = (testCallback driver options) |> Task.result!
    endTime = Utc.now!
    duration = (Utc.deltaAsMillis startTime endTime) |> Num.toU64
    Task.ok {
        name: name,
        result: result,
        duration,
    }

errorToStr = \result ->
    when result is
        WebDriverError msg ->
            "WebDriverError: $(msg)"

        AssertionError msg ->
            "AssertionError: $(msg)"

        err ->
            msg = Inspect.toStr err
            "UnknownError: $(msg)"

color = {
    gray: "\u(001b)[4;90m",
    red: "\u(001b)[91m",
    green: "\u(001b)[92m",
    end: "\u(001b)[0m",
}

TestRunnerOptions : {
    printToConsole ? Bool,
    screenshotOnFail ? Bool,
    # TODO compiler error
    # reporters ? List Reporting.ReporterDefinition,
    outDir ? Str,
}

defaultOutDir = "testResults"
# defaultReporters : List Reporting.ReporterDefinition
defaultReporters = []
# defaultReporters : List Reporting.ReporterDefinition
# defaultReporters = [Reporting.basicHtmlReporter]

## Run a list of r2e tests.
##
## Available options:
## ```
## TestRunnerOptions : {
##    printToConsole ? Bool, # should print results to Stdout? Default: `Bool.true`
## }
## ```
## ```
## myTest = test "open roc-lang.org website" \browser ->
##     # open roc-lang.org
##     browser |> Browser.navigateTo! "http://roc-lang.org"
##
## main =
##     testResults = Test.runAllTests! [myTest] {}
##     Test.getResultCode! testResults
## ```
# runAllTests : List TestDefinition, TestRunnerOptions -> Task.Task {} _
runAllTests = \tasks, { printToConsole ? Bool.true, screenshotOnFail ? Bool.true, outDir ? defaultOutDir, reporters ? defaultReporters, driver ? Driver.create {} } ->
    printToConsole |> runIf! (Stdout.line "Starting test run...")
    testStartTime = Utc.now!
    allCount = tasks |> List.len
    # Task.seq and Task.forEach do not work for this - compiler bug
    (_, allResults) = Task.loop! (tasks, []) \(remainingTests, results) ->
        when remainingTests is
            [] -> Task.ok (Done ([], results))
            [task, .. as rest] ->
                testIndex = allCount - (rest |> List.len)
                printToConsole |> runIf! (printTestHeader task testIndex)
                result = task |> runTest! driver { screenshotOnFail }
                printToConsole |> runIf! (printTestResult task testIndex result.result)
                newResults = List.append results result
                Task.ok (Step (rest, newResults))
    printToConsole |> runIf! (printResultSummary allResults)
    testEndTime = Utc.now!
    testsDuration = (Utc.deltaAsMillis testStartTime testEndTime) |> Num.toU64
    reporters |> InternalReporting.runReporters! allResults outDir testsDuration
    allResults |> getResultCode

runIf : Bool, Task.Task {} _ -> Task.Task {} _
runIf = \condition, task ->
    if condition then
        task
    else
        Task.ok {}

printTestHeader = \@TestDefinition { name }, index ->
    indexStr = index |> Num.toStr
    Stdout.line! "" # empty line for readability
    Stdout.line "$(color.gray)Test $(indexStr):$(color.end) \"$(name)\": Running..."

printTestResult = \@TestDefinition { name }, index, result ->
    indexStr = index |> Num.toStr
    when result is
        Ok {} -> Stdout.line "$(color.gray)Test $(indexStr):$(color.end) \"$(name)\": $(color.green)OK$(color.end)"
        Err (ErrorMsg e) -> Stdout.line "$(color.gray)Test $(indexStr):$(color.end) \"$(name)\": $(color.red)$(e)$(color.end)"
        Err (ErrorMsgWithScreenshot e _) -> Stdout.line "$(color.gray)Test $(indexStr):$(color.end) \"$(name)\": $(color.red)$(e)$(color.end)"

printResultSummary : List TestRunResult -> Task.Task {} _
printResultSummary = \results ->
    # empty line
    Stdout.line! ""
    Stdout.line! "Summary:"

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

getResultCode : List TestRunResult -> Task.Task {} [Exit I32 Str]
getResultCode = \results ->
    anyFailures =
        results
        |> List.any \{ result } -> result |> Result.isErr

    if anyFailures then
        Task.err (Exit 1 "Test run failed")
    else
        Task.ok {}

