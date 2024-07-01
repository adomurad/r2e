app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.11.0/SY4WWMhWQ9NvQgvIthcv15AUeA7rAIJHAHgiaSHGhdY.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.10.0/KbIfTNbxShRX1A1FgXei1SpO5Jn8sgP6HP6PXbi-xyA.tar.br",
    # r2e: "https://github.com/adomurad/r2e/releases/download/v0.1.2-alpha/7av1ULbhNFk9iyUA4KSPBDozlNftjsC7BSQkgcsw1TI.tar.br",
    r2e: "../package/main.roc",
}

import pf.Stdout
import pf.Task
import r2e.Test exposing [test]
import r2e.Browser
import r2e.Element
import r2e.Assert

main =
    Stdout.line! "Starting test suite!"

    tasks = [test1, test2]

    # run all tests
    results = Test.runAllTests! tasks
    # print results to Stdout
    Test.printResults! results
    # return an exit code for the cli
    results |> Test.getResultCode

test1 = test "check roc header" \browser ->
    # go to roc-lang.org
    browser |> Browser.navigateTo! "http://roc-lang.org"
    # find header text
    header = browser |> Browser.findElement! (Css "#homepage-h1")
    # get header text
    headerText = header |> Element.getText!
    # check text
    headerText |> Assert.shouldBe "Roc"

test2 = test "use roc repl" \browser ->
    # go to roc-lang.org
    browser |> Browser.navigateTo! "http://roc-lang.org"
    # find repl input
    replInput = browser |> Browser.findElement! (Css "#source-input")
    # send keys to repl
    replInput |> Element.sendKeys! "0.1+0.2{enter}"
    # find repl output element
    outputEl = browser |> Browser.findElement! (Css ".output")
    # get output text
    outputText = outputEl |> Element.getText!
    # assert text - fail for demo purpose
    outputText |> Assert.shouldBe "0.3000000001 : Frac *"