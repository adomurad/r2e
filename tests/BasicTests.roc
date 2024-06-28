module [
    test1,
    test2,
    test3,
    test5,
]

import pf.Stdout
import pf.Task
import driver.Driver
import driver.Browser
import driver.Element
import driver.Assert
import driver.Test exposing [test]

# https://devexpress.github.io/testcafe/example/

test5 = test "go to google and click some stuff" \browser ->
    browser |> Browser.navigateTo! "http://google.com"
    button = browser |> Browser.findElement! (Css "#L2AGLb")
    # get the text of the button
    buttonText = button |> Element.getText!
    Stdout.line! "Button text is: $(buttonText)"
    # assert button text
    buttonText |> Assert.shouldBe! "Close Button"
    # click the button
    button |> Element.click!
    Stdout.line! "Test End"

test1 =
    driver = Driver.create LocalServerWithDefaultPort
    # open the page http://google.com in browser
    browser = Browser.open! driver "http://google.com"
    Browser.runWithCleanup! browser \_ ->
        # find the html element with a css selector "#L2AGLb"
        button = browser |> Browser.findElement! (Css "#L2AGLb")

        # get the text of the button
        buttonText = button |> Element.getText!
        Stdout.line! "Button text is: $(buttonText)"
        # assert button text
        buttonText |> Assert.shouldBe! "Close Button"
        # click the button
        button |> Element.click!
    Stdout.line! "Test End"

test3 =
    driver = Driver.create LocalServerWithDefaultPort
    # open the page http://google.com in browser
    Browser.openWithCleanup! driver "http://google.com" \browser ->
        # find the html element with a css selector "#L2AGLb"
        button = browser |> Browser.findElement! (Css "#L2AGLb")

        # get the text of the button
        buttonText = button |> Element.getText!
        Stdout.line! "Button text is: $(buttonText)"
        # assert button text
        buttonText |> Assert.shouldBe! "Close Button"
        # click the button
        button |> Element.click!
    Stdout.line! "Test End"

test2 =
    driver = Driver.create LocalServerWithDefaultPort
    browser = Browser.open! driver "http://google.com"

    foundButton = browser |> Browser.tryFindElement! (Css "#L2AGLb")

    when foundButton is
        Found button ->
            buttonText = button |> Element.getText!
            Stdout.line! "Button found. Button text is: $(buttonText)"
            browser |> Browser.close!

        NotFound ->
            Stdout.line! "Button not found!"
            browser |> Browser.close!

# Stdout.line "Test End"

