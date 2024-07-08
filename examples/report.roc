app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.12.0/cf_TpThUd4e69C7WzHxCbgsagnDmk3xlb_HmEKXTICw.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.10.0/KbIfTNbxShRX1A1FgXei1SpO5Jn8sgP6HP6PXbi-xyA.tar.br",
    r2e: "../package/main.roc",
}

import pf.Stdout
import pf.Task
import r2e.Browser
import r2e.Element
import r2e.Test exposing [test]
import r2e.Reporting
import r2e.Reporting.BasicHtmlReporter as BasicHtmlReporter

customReporter = Reporting.createReporter "myCustomReporter" \results ->
    lenStr = results |> List.len |> Num.toStr
    indexFile = { filePath: "index.html", content: "<h3>Test count: $(lenStr)</h3>" }
    testFile = { filePath: "test.txt", content: "this is just a test" }
    [indexFile, testFile]

main : Task.Task {} _
main =
    tests = [
        test1,
        test2,
    ]

    # run without reporters -default for now
    _ = tests |> Test.runAllTests {} |> Task.result!
    # run with reporters
    _ =
        tests
            |> Test.runAllTests {
                reporters: [BasicHtmlReporter.reporter, customReporter],
            }
            |> Task.result!

    # run without screenshots
    tests
    |> Test.runAllTests {
        reporters: [BasicHtmlReporter.reporter],
        screenshotOnFail: Bool.false,
    }

test1 = test "Fail finding button" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    # this fails
    button = browser |> Browser.findElement! (Css "#submit-button-fake")
    buttonText = button |> Element.getText!
    Stdout.line! "Button text is: $(buttonText)"

test2 = test "Fail with custom error" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    # this fails
    Task.err! (MyCustomError "this failed")
    Stdout.line! "will not reach this line"
