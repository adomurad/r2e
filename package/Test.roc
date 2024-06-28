module [test, runTest, printResults, runAllTests]

import pf.Task exposing [Task]
import pf.Stdout
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

color = {
    gray: "\u(001b)[4;90m",
    red: "\u(001b)[91m",
    green: "\u(001b)[92m",
    end: "\u(001b)[0m",
}

printResults : List { name : Str, result : Result {} [ErrorMsg Str] } -> Task.Task {} _
printResults = \results ->
    Stdout.line! "Results:"
    tasks = List.mapWithIndex results \res, i ->
        index = i |> Num.toStr
        when res.result is
            Ok {} -> Stdout.line "$(color.gray)Test $(index):$(color.end) \"$(res.name)\": $(color.green)OK$(color.end)"
            Err (ErrorMsg e) -> Stdout.line "$(color.gray)Test $(index):$(color.end) \"$(res.name)\": $(color.red)$(e)$(color.end)"

    Task.seq tasks |> Task.map \_ -> {}

runAllTests : List { name : a, testBody : Task.Task ok err }* -> Task.Task (List { name : a, result : Result ok err }) *
runAllTests = \tasks ->
    # Task.seq and Task.forEach do not work for this - compiler bug
    (_, allResults) = Task.loop! (tasks, []) \(remaingTests, results) ->
        when remaingTests is
            [] -> Task.ok (Done ([], results))
            [task, .. as rest] ->
                result = task |> Test.runTest!
                newResults = List.append results result
                Task.ok (Step (rest, newResults))

    Task.ok allResults
