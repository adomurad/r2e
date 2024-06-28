module [
    open,
    createBrowser,
    createBrowserWithCleanup,
    navigateTo,
    openWithCleanup,
    close,
    runWithCleanup,
    findElement,
    findElements,
    tryFindElement,
]

import pf.Task exposing [Task]
import WebDriver exposing [LocatorStrategy]
import Internal exposing [Driver, Browser, Element]
import Error exposing [toWebDriverError, R2EError]

# ----------------------------------------------------------------

open : Driver, Str -> Task Browser R2EError
open = \driver, url ->
    { serverUrl } = Internal.unpackDriverData driver

    sessionId =
        WebDriver.startSession serverUrl
            |> Task.mapErr! toWebDriverError
    WebDriver.navigateTo serverUrl sessionId url
        |> Task.mapErr! toWebDriverError

    Internal.packBrowserData { sessionId, serverUrl } |> Task.ok

createBrowser : Driver -> Task Browser R2EError
createBrowser = \driver ->
    { serverUrl } = Internal.unpackDriverData driver

    sessionId =
        WebDriver.startSession serverUrl
            |> Task.mapErr! toWebDriverError

    Internal.packBrowserData { sessionId, serverUrl } |> Task.ok

createBrowserWithCleanup : Driver, (Browser -> Task {} _) -> Task {} _
createBrowserWithCleanup = \driver, task ->
    browser = createBrowser! driver
    runWithCleanup browser task

navigateTo : Browser, Str -> Task {} R2EError
navigateTo = \browser, url ->
    { serverUrl, sessionId } = Internal.unpackBrowserData browser
    WebDriver.navigateTo serverUrl sessionId url
        |> Task.mapErr! toWebDriverError

    {} |> Task.ok

openWithCleanup : Driver, Str, (Browser -> Task {} _) -> Task {} _
openWithCleanup = \driver, url, task ->
    browser = open! driver url
    runWithCleanup browser task

close : Browser -> Task {} R2EError
close = \browser ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser
    WebDriver.deleteSession serverUrl sessionId
        |> Task.mapErr! toWebDriverError

    {} |> Task.ok

runWithCleanup : Browser, (Browser -> Task a _) -> Task a _
runWithCleanup = \browser, task ->
    result = task browser |> Task.result!
    browser |> Browser.close!
    result |> Task.fromResult

findElement : Browser, LocatorStrategy -> Task Element R2EError
findElement = \browser, locator ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser

    elementId =
        WebDriver.findElement serverUrl sessionId locator
            |> Task.mapErr! \err ->
                when err is
                    HttpErr (BadStatus 404) ->
                        (_, locatorValue) = WebDriver.getLocator locator
                        WebDriverError "element ($(locatorValue)) not found"

                    e -> toWebDriverError e

    Internal.packElementData { sessionId, serverUrl, elementId } |> Task.ok

findElements : Browser, LocatorStrategy -> Task (List Element) R2EError
findElements = \browser, locator ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser

    elementIds =
        WebDriver.findElements serverUrl sessionId locator
            |> Task.mapErr! toWebDriverError

    elements =
        elementIds
        |> List.map \elementId ->
            Internal.packElementData { sessionId, serverUrl, elementId }

    elements |> Task.ok

tryFindElement : Browser, LocatorStrategy -> Task [Found Element, NotFound] R2EError
tryFindElement = \browser, locator ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser

    result = WebDriver.findElement serverUrl sessionId locator |> Task.result!

    when result is
        Ok elementId ->
            Internal.packElementData { sessionId, serverUrl, elementId } |> Found |> Task.ok

        Err (HttpErr (BadStatus 404)) ->
            NotFound |> Task.ok

        Err err ->
            err |> toWebDriverError |> Task.err

