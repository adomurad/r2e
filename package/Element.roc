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

getText : Internal.Element -> Task.Task Str [WebDriverError Str]
getText = \element ->
    { sessionId, serverUrl, elementId } = Internal.unpackElementData element

    text =
        WebDriver.getElementText serverUrl sessionId elementId
            |> Task.mapErr! toWebDriverError

    text |> Task.ok

click : Internal.Element -> Task.Task {} [WebDriverError Str]
click = \element ->
    { sessionId, serverUrl, elementId } = Internal.unpackElementData element
    WebDriver.clickElement serverUrl sessionId elementId
        |> Task.mapErr! toWebDriverError

    {} |> Task.ok

enterKey = "\\uE007"

sendKeys : Internal.Element, Str -> Task.Task {} [WebDriverError Str]
sendKeys = \element, str ->
    { sessionId, serverUrl, elementId } = Internal.unpackElementData element
    keysToSend = str |> replaceSequence "{enter}" enterKey
    WebDriver.sendKeys serverUrl sessionId elementId keysToSend
        |> Task.mapErr! toWebDriverError

    {} |> Task.ok

replaceSequence : Str, Str, Str -> Str
replaceSequence = \str, old, new ->
    str |> Str.replaceEach old new
