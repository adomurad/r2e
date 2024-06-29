## `Element` module contains function to interact with `Elements`
## found in the `Browser`.
module [
    getText,
    click,
    sendKeys,
]

import pf.Task
import WebDriver
import Internal
import Error exposing [toWebDriverError]

# ----------------------------------------------------------------

## Get text of the `Element`.
##
## ```
## # find button element
## button = browser |> Browser.findElement! (Css "#submit-button")
## # get button text
## buttonText = button |> Element.getText!
## ```
getText : Internal.Element -> Task.Task Str [WebDriverError Str]
getText = \element ->
    { sessionId, serverUrl, elementId } = Internal.unpackElementData element

    text =
        WebDriver.getElementText serverUrl sessionId elementId
            |> Task.mapErr! toWebDriverError

    text |> Task.ok

## Click on a `Element`.
##
## ```
## # find button element
## button = browser |> Browser.findElement! (Css "#submit-button")
## # click the button
## button |> Element.click!
## ```
click : Internal.Element -> Task.Task {} [WebDriverError Str]
click = \element ->
    { sessionId, serverUrl, elementId } = Internal.unpackElementData element
    WebDriver.clickElement serverUrl sessionId elementId
        |> Task.mapErr! toWebDriverError

    {} |> Task.ok

enterKeyCode = "\\uE007"

## Send keys to a `Element` (e.g. put text into an input).
##
## WARNING - input text is not escaped for now
## double quotes need to be escaped manually e.g. "my input \"test\""
##
## ```
## # find email input element
## emailInput = browser |> Browser.findElement! (Css "#email")
## # input an email into the email input
## emailInput |> Element.sendKeys! "my.fake.email@fake-email.com"
## ```
##
## Special key sequences:
##
## `{enter}` - simulates an "enter" key press
##
## ```
## # find search input element
## searchInput = browser |> Browser.findElement! (Css "#search")
## # input text and submit
## searchInput |> Element.sendKeys! "roc lang{enter}"
## ```
sendKeys : Internal.Element, Str -> Task.Task {} [WebDriverError Str]
sendKeys = \element, str ->
    { sessionId, serverUrl, elementId } = Internal.unpackElementData element
    keysToSend = str |> replaceSequence "{enter}" enterKeyCode
    WebDriver.sendKeys serverUrl sessionId elementId keysToSend
        |> Task.mapErr! toWebDriverError

    {} |> Task.ok

replaceSequence : Str, Str, Str -> Str
replaceSequence = \str, old, new ->
    str |> Str.replaceEach old new
