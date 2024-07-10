## `Element` module contains function to interact with `Elements`
## found in the `Browser`.
module [
    getText,
    getAttribute,
    getProperty,
    getValue,
    click,
    clear,
    sendKeys,
    getScreenshotBase64,
    getScreenshot,
]

import pf.Task
import base64.Base64
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

## Get **value** of the `Element`.
##
## When there is no **value** in this element then returns empty `Str`.
##
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#email-input")
## # get input value
## inputValue = input |> Element.getValue!
## ```
getValue : Internal.Element -> Task.Task Str [WebDriverError Str]
getValue = \element ->
    getProperty element "value"
    |> Task.map \task ->
        task
        |> Result.withDefault ""

## Get **attribute** of an `Element`.
##
## Returns a `Task` of `Result Str [Empty]`
##
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#email-input")
## # get input value
## inputValue = input |> Element.getAttribute! "value"
## ```
getAttribute : Internal.Element, Str -> Task.Task (Result Str [Empty]) [WebDriverError Str]
getAttribute = \element, attributeName ->
    { sessionId, serverUrl, elementId } = Internal.unpackElementData element

    text =
        WebDriver.getElementAttribute serverUrl sessionId elementId attributeName
            |> Task.mapErr! toWebDriverError

    text |> Task.ok

# TODO - check if numbers are number :(
## Get **property** of an `Element`.
##
## Returns a `Task` of `Result a [Empty]`
##
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#email-input")
## # get input value
## inputValue = input |> Element.getAttribute! "value"
## ```
getProperty : Internal.Element, Str -> Task.Task (Result a [Empty]) [WebDriverError Str]
getProperty = \element, propertyName ->
    { sessionId, serverUrl, elementId } = Internal.unpackElementData element

    text =
        WebDriver.getElementProperty serverUrl sessionId elementId propertyName
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

## Clear an editable or resettable `Element`.
##
## ```
## # find button element
## input = browser |> Browser.findElement! (Css "#email-input")
## # click the button
## input |> Element.clear!
## ```
clear : Internal.Element -> Task.Task {} [WebDriverError Str]
clear = \element ->
    { sessionId, serverUrl, elementId } = Internal.unpackElementData element
    WebDriver.clearElement serverUrl sessionId elementId
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

## Take a screenshot of a `Element`.
##
## The result will be a **base64** encoded `Str` representation of a PNG file.
##
## ```
## base64PngStr = button |> Element.getScreenshotBase64!
## ```
getScreenshotBase64 : Internal.Element -> Task.Task Str [WebDriverError Str]
getScreenshotBase64 = \element ->
    { sessionId, serverUrl, elementId } = Internal.unpackElementData element

    WebDriver.takeElementScreenshot serverUrl sessionId elementId
    |> Task.mapErr toWebDriverError

## Take a screenshot of a `Element`.
##
## The result will be a **base64** encoded `List U8` representation of a PNG file.
##
## ```
## pngBytes = button |> Element.getScreenshot!
## ```
getScreenshot : Internal.Element -> Task.Task (List U8) [WebDriverError Str]
getScreenshot = \element ->
    { sessionId, serverUrl, elementId } = Internal.unpackElementData element

    WebDriver.takeElementScreenshot serverUrl sessionId elementId
    |> Task.map \value -> value |> Base64.decodeStr
    |> Task.mapErr toWebDriverError

