app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.11.0/SY4WWMhWQ9NvQgvIthcv15AUeA7rAIJHAHgiaSHGhdY.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.10.0/KbIfTNbxShRX1A1FgXei1SpO5Jn8sgP6HP6PXbi-xyA.tar.br",
    r2e: "../package/main.roc",
}

import pf.Stdout
import pf.Task
import r2e.Test exposing [customTest]
import r2e.Browser
import r2e.Element
import r2e.Assert
import r2e.Driver

driver = Driver.create { connection: RemoteServer "http://localhost:9515" }
test = customTest driver

main =
    Stdout.line! "Starting test suite!"

    tasks = [test1]

    Test.runAllTests tasks {}

test1 = test "open roc-lang.org website" \browser ->
    # open roc-lang.org
    browser |> Browser.navigateTo! "http://roc-lang.org"
    # find header text
    header = browser |> Browser.findElement! (Css "#homepage-h1")
    # get header text
    headerText = header |> Element.getText!
    # check text
    headerText |> Assert.shouldBe! "Roc"

