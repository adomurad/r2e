app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.11.0/SY4WWMhWQ9NvQgvIthcv15AUeA7rAIJHAHgiaSHGhdY.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.10.0/KbIfTNbxShRX1A1FgXei1SpO5Jn8sgP6HP6PXbi-xyA.tar.br",
    driver: "./src/main.roc",
}

import pf.Stdout
import pf.Task
import driver.Test
import Tests.BasicTests as BasicTests

main =
    Stdout.line! "Starting test suite!"

    # tests = [
    #     BasicTests.test1,
    #     BasicTests.test2,
    # ]

    # result = Task.seq tests |> Task.result!
    { result } = BasicTests.test5 |> Test.runTest!

    # Stdout.line "Success!"
    when result is
        Ok {} -> Stdout.line "OK"
        Err (ErrorMsg msg) -> Stdout.line msg
# result = Task.forEach! tests \task -> task |> Task.mapErr \_ -> Ups

# when result is
#     # _ -> Stdout.line "Success!"
#     Ok _ -> Stdout.line "Success!"
#     Err (WebDriverError msg) ->
#         Stdout.line "WebDriverError: $(msg)"

#     Err (StdoutErr _) ->
#         Stdout.line "StdoutErr"

#     Err (AssertionError msg) ->
#         Stdout.line "AssertionError: $(msg)"

