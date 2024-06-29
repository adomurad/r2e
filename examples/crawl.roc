app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.11.0/SY4WWMhWQ9NvQgvIthcv15AUeA7rAIJHAHgiaSHGhdY.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.10.0/KbIfTNbxShRX1A1FgXei1SpO5Jn8sgP6HP6PXbi-xyA.tar.br",
    r2e: "../package/main.roc",
}

import pf.Stdout
import pf.Task
import r2e.Browser
import r2e.Element
import r2e.Driver

main =
    test1!
    test2!
    test3!

test1 =
    Stdout.line! ">> Create driver - basic usage"
    # create a driver client for http://localhost:9515
    driver = Driver.create LocalServerWithDefaultPort

    # open the page http://google.com in browser
    browser = Browser.open! driver "http://google.com"

    # find the html element with a css selector "#L2AGLb"
    button = browser |> Browser.findElement! (Css "#L2AGLb")

    # get the text of the button
    buttonText = button |> Element.getText!
    Stdout.line! "Button text is: $(buttonText)"
    # click the button
    button |> Element.click!
    # close the browser
    browser |> Browser.close!
    Stdout.line! "<< Create driver - basic usage END"

test2 =
    Stdout.line! ">> Browser.createBrowserWithCleanup"
    driver = Driver.create LocalServerWithDefaultPort
    task =
        Browser.createBrowserWithCleanup driver \browser ->
            browser |> Browser.navigateTo! "http://google.com"
            # should cleanup and close the browser
            Task.err (RandomError)
    _ = task |> Task.result!
    # ignore errors
    Stdout.line! "<< Browser.createBrowserWithCleanup END"

test3 =
    Stdout.line! ">> Browser.openWithCleanup"
    driver = Driver.create LocalServerWithDefaultPort
    task =
        url = "http://google.com"
        Browser.openWithCleanup! driver url \browser ->
            # browser opens at google.com
            # should cleanup and close the browser when not found
            _ = browser |> Browser.findElement! (Css "#fake-id-abcd")
            Stdout.line! "unreachable"

    _ = task |> Task.result!
    # ignore errors
    Stdout.line! "<< Browser.openWithCleanup END"
