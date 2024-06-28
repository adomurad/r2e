app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.11.0/SY4WWMhWQ9NvQgvIthcv15AUeA7rAIJHAHgiaSHGhdY.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.10.0/KbIfTNbxShRX1A1FgXei1SpO5Jn8sgP6HP6PXbi-xyA.tar.br",
    r2e: "../package/main.roc",
}

import pf.Stdout
import pf.Task
import r2e.Test exposing [test]
import r2e.Browser
import r2e.Element
import r2e.Assert
import pf.Sleep

main =
    Stdout.line! "Starting test suite!"

    tasks = [test1, test2]

    results = Test.runAllTests! tasks
    Test.printResults! results

test1 = test "find roc in google" \browser ->
    # open google
    browser |> Browser.navigateTo! "http://google.com"
    # find cookie confirm button
    button = browser |> Browser.findElement! (Css "#L2AGLb")
    # confirm cookies
    button |> Element.click!
    # find search input
    searchInput = browser |> Browser.findElement! (Css ".gLFyf")
    # search for "roc lang"
    searchInput |> Element.sendKeys! "roc lang{enter}"
    # wait for demo purpose
    Sleep.millis! 500
    # find all search results
    searchResults = browser |> Browser.findElements! (Css ".yuRUbf")
    # get first result
    firstSearchResult = searchResults |> List.first |> Task.fromResult!
    # click on first result
    firstSearchResult |> Element.click!
    # wait for demo purpose
    Sleep.millis! 1000
    # find header text
    header = browser |> Browser.findElement! (Css "#homepage-h1")
    # get header text
    headerText = header |> Element.getText!
    # check text
    headerText |> Assert.shouldBe! "Roc"

test2 = test "use repl" \browser ->
    # go to roc-lang.org
    browser |> Browser.navigateTo! "http://roc-lang.org"
    # find repl input
    replInput = browser |> Browser.findElement! (Css "#source-input")
    # send keys to repl
    replInput |> Element.sendKeys! "1 + 2{enter}"
    # wait for demo purpose
    Sleep.millis! 2000
    # find repl output element
    outputEl = browser |> Browser.findElement! (Css ".output")
    # get output text
    outputText = outputEl |> Element.getText!
    # assert text - fail for demo purpose
    outputText |> Assert.shouldBe "3.000000001 : Num *"
