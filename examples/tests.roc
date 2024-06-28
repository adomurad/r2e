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

main =
    Stdout.line! "Starting test suite!"

    # can't run the whole suite - compiler error on Task.seq and Task.forEach
    { result } = test1 |> Test.runTest!

    when result is
        Ok {} -> Stdout.line "OK"
        Err (ErrorMsg msg) -> Stdout.line msg

test1 = test "go to google and click some stuff" \browser ->
    browser |> Browser.navigateTo! "http://google.com"
    button = browser |> Browser.findElement! (Css "#L2AGLb")
    # get the text of the button
    buttonText = button |> Element.getText!
    Stdout.line! "Button text is: $(buttonText)"
    # assert button text
    buttonText |> Assert.shouldBe! "Accept all"
    # click the button
    button |> Element.click!
    Stdout.line! "Test End"

test2 = test "check if exists" \browser ->
    browser |> Browser.navigateTo! "http://google.com"
    foundButton = browser |> Browser.tryFindElement! (Css "#L2AGLb")

    when foundButton is
        Found button ->
            buttonText = button |> Element.getText!
            Stdout.line "Button found. Button text is: $(buttonText)"

        NotFound ->
            Stdout.line "Button not found!"
