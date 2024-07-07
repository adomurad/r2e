app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.12.0/cf_TpThUd4e69C7WzHxCbgsagnDmk3xlb_HmEKXTICw.tar.br",
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
    test4!
    test5!
    test6!

test1 =
    Stdout.line! ">> Create driver - basic usage"
    # create a driver client for http://localhost:9515
    driver = Driver.create {}

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
    driver = Driver.create {}
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
    driver = Driver.create {}
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

test4 =
    Stdout.line! ">> Browser.setWindowRect"
    # create a driver client for http://localhost:9515
    driver = Driver.create {}

    # create 2 browser windows
    browser1 = Browser.createBrowser! driver
    # create 2 browser windows
    browser2 = Browser.createBrowser! driver
    # navigate browser1 to basic-cli
    browser1 |> Browser.navigateTo! "https://www.roc-lang.org/packages/basic-cli/"
    # navigate browser2 to basic-webserver
    browser2 |> Browser.navigateTo! "https://roc-lang.github.io/basic-webserver/"
    browser1
        |> Browser.setWindowRect! {
            x: Some 0,
            y: Some 0,
        }
    browser2
        |> Browser.setWindowRect! {
            width: Some 100,
            height: Some 100,
        }
    # close browser1
    browser1 |> Browser.close!
    # close browser2
    browser2 |> Browser.close!
    Stdout.line! "<< Browser.setWindowRect END"

test5 =
    Stdout.line! ">> Browser.setSize"
    # create a driver client for http://localhost:9515
    driver = Driver.create {}

    # create 2 browser windows
    browser = Browser.createBrowser! driver
    # navigate browser1 to basic-cli
    browser |> Browser.navigateTo! "https://www.roc-lang.org/packages/basic-cli/"
    # set size 100x800
    browser |> Browser.setSize! 100 800
    # close browser
    browser |> Browser.close!
    Stdout.line! "<< Browser.setSize END"

test6 =
    Stdout.line! ">> Browser.moveTo"
    # create a driver client for http://localhost:9515
    driver = Driver.create {}

    # create 2 browser windows
    browser = Browser.createBrowser! driver
    # navigate browser1 to basic-cli
    browser |> Browser.navigateTo! "https://www.roc-lang.org/packages/basic-cli/"
    # move to 100x800
    browser |> Browser.moveTo! 100 800
    # close browser
    browser |> Browser.close!
    Stdout.line! "<< Browser.moveTo END"
