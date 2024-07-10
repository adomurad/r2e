## `Browser` module contains function to interact with the `Browser`.
module [
    open,
    createBrowser,
    createBrowserWithCleanup,
    navigateTo,
    openWithCleanup,
    close,
    # runWithCleanup,
    findElement,
    findElements,
    tryFindElement,
    Locator,
    setWindowRect,
    setSize,
    moveTo,
    getTitle,
    getUrl,
    navigateBack,
    navigateForward,
    reloadPage,
    maximizeWindow,
    minimizeWindow,
    fullScreenWindow,
    printPdfBase64,
    printPdf,
    getScreenshotBase64,
    getScreenshot,
]

import pf.Task exposing [Task]
import base64.Base64
import WebDriver exposing [LocatorStrategy]
import Internal exposing [Driver, Browser, Element]
import Error exposing [toWebDriverError, R2EError]

# ----------------------------------------------------------------

## Open a new browser window and navigate to the given URL.
##
## ```
## # create a driver client for http://localhost:9515
## driver = Driver.create LocalServerWithDefaultPort
## # create browser and open the page http://google.com
## browser = Browser.open! driver "http://google.com"
## ```
open : Driver, Str -> Task Browser R2EError
open = \driver, url ->
    { serverUrl } = Internal.unpackDriverData driver

    sessionId =
        WebDriver.startSession serverUrl
            |> Task.mapErr! toWebDriverError
    WebDriver.navigateTo serverUrl sessionId url
        |> Task.mapErr! toWebDriverError

    Internal.packBrowserData { sessionId, serverUrl } |> Task.ok

## Open a new browser window and navigates to the given URL
## with a callback function.
## When the callback function ends on `Task.ok` or `Task.err`
## the browser window will be automatically closed.
##
## ```
## url = "http://google.com"
## Browser.openWithCleanup! driver url \browser ->
##     # browser opens at google.com
##     # should cleanup and close the browser when not found
##     el = browser |> Browser.findElement! (Css "#fake-id-abcd")
## ```
openWithCleanup : Driver, Str, (Browser -> Task {} _) -> Task {} _
openWithCleanup = \driver, url, task ->
    browser = open! driver url
    runWithCleanup browser task

## Open a new browser window on a blank page.
##
## ```
## # create a driver client for http://localhost:9515
## driver = Driver.create LocalServerWithDefaultPort
## # open empty browser
## browser = Browser.createBrowser! driver
## ```
createBrowser : Driver -> Task Browser R2EError
createBrowser = \driver ->
    { serverUrl } = Internal.unpackDriverData driver

    sessionId =
        WebDriver.startSession serverUrl
            |> Task.mapErr! toWebDriverError

    Internal.packBrowserData { sessionId, serverUrl } |> Task.ok

## Open a new browser window with a callback function.
## When the callback function ends on `Task.ok` or `Task.err`
## the browser window will be automatically closed.
##
## ```
## Browser.createBrowserWithCleanup driver \browser ->
##     browser |> Browser.navigateTo! "http://google.com"
##     # should cleanup and close the browser
## Task.err (RandomError)
## ```
createBrowserWithCleanup : Driver, (Browser -> Task {} _) -> Task {} _
createBrowserWithCleanup = \driver, task ->
    browser = createBrowser! driver
    runWithCleanup browser task

## Navigate the browser to the given URL.
##
## ```
## # create a driver client for http://localhost:9515
## driver = Driver.create LocalServerWithDefaultPort
## # open empty browser
## browser = Browser.createBrowser! driver
## # open google.com
## browser |> Browser.navigateTo! "http://google.com"
## ```
navigateTo : Browser, Str -> Task {} R2EError
navigateTo = \browser, url ->
    { serverUrl, sessionId } = Internal.unpackBrowserData browser
    WebDriver.navigateTo serverUrl sessionId url
        |> Task.mapErr! toWebDriverError

    {} |> Task.ok

## Close the browser window.
##
## ```
## # create a driver client for http://localhost:9515
## driver = Driver.create LocalServerWithDefaultPort
## # create browser and open the page http://google.com
## browser = Browser.open! driver "http://google.com"
## # close the browser
## browser |> Browser.close!
## ```
close : Browser -> Task {} R2EError
close = \browser ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser
    WebDriver.deleteSession serverUrl sessionId
        |> Task.mapErr! toWebDriverError

    {} |> Task.ok

# internal
runWithCleanup : Browser, (Browser -> Task a _) -> Task a _
runWithCleanup = \browser, task ->
    result = task browser |> Task.result!
    browser |> Browser.close!
    result |> Task.fromResult

## Supported locator strategies
##
## `Css Str` - e.g. Css ".my-button-class"
##
## `TestId Str` - e.g. TestId "button" => Css "[data-testid=\"button\"]"
##
## `XPath Str` - e.g. XPath "/bookstore/book[price>35]/price"
##
Locator : [
    Css Str,
    TestId Str,
    XPath Str,
]

getDriverLocator : Locator -> LocatorStrategy
getDriverLocator = \locator ->
    when locator is
        Css str -> Css str
        TestId str -> Css "[data-testid=\"$(str)\"]"
        XPath str -> XPath str

## Find a `Element` in the `Browser`.
##
## When there are more than 1 elements, then the first will
## be returned.
##
## See supported locators at `Locator`.
##
## ```
## # find the html element with a css selector "#my-id"
## button = browser |> Browser.findElement! (Css "#my-id")
## ```
##
## ```
## # find the html element with a css selector ".my-class"
## button = browser |> Browser.findElement! (Css ".my-class")
## ```
##
## ```
## # find the html element with an attribute [data-testid="my-element"]
## button = browser |> Browser.findElement! (TestId "my-element")
## ```
findElement : Browser, Locator -> Task Element R2EError
findElement = \browser, locator ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser

    driverLocator = getDriverLocator locator

    elementId =
        WebDriver.findElement serverUrl sessionId driverLocator
            |> Task.mapErr! \err ->
                when err is
                    # HttpErr (BadStatus { code: 404, body: _ }) ->
                    HttpErr (BadStatus 404) ->
                        (_, locatorValue) = WebDriver.getLocator driverLocator
                        WebDriverError "element ($(locatorValue)) not found"

                    e -> toWebDriverError e

    Internal.packElementData { sessionId, serverUrl, elementId } |> Task.ok

# TODO add findSingleElement - error when not exact 1 element

## Find all `Elements` in the `Browser`.
##
## When there are no elements found, then the list will be empty.
##
## See supported locators at `Locator`.
##
## ```
## # find all <li> elements in #my-list
## listItems = browser |> Browser.findElements! (Css "#my-list li")
## ```
##
findElements : Browser, Locator -> Task (List Element) R2EError
findElements = \browser, locator ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser

    driverLocator = getDriverLocator locator

    elementIds =
        WebDriver.findElements serverUrl sessionId driverLocator
            |> Task.mapErr! toWebDriverError

    elements =
        elementIds
        |> List.map \elementId ->
            Internal.packElementData { sessionId, serverUrl, elementId }

    elements |> Task.ok

## Find a `Element` in the `Browser`.
##
## This function returns a `[Found Element, NotFound]` instead of an error
## when element is not found.
##
## When there are more than 1 elements, then the first will
## be returned.
##
## See supported locators at `Locator`.
##
## ```
## maybeButton = browser |> Browser.tryFindElement! (Css "#submit-button")
##
## when maybeButton is
##     NotFound -> Stdout.line! "Button not found"
##     Found el ->
##         buttonText = el |> Element.getText!
##         Stdout.line! "Button found with text: $(buttonText)"
## ```
##
tryFindElement : Browser, Locator -> Task [Found Element, NotFound] R2EError
tryFindElement = \browser, locator ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser

    driverLocator = getDriverLocator locator

    result = WebDriver.findElement serverUrl sessionId driverLocator |> Task.result!

    when result is
        Ok elementId ->
            Internal.packElementData { sessionId, serverUrl, elementId } |> Found |> Task.ok

        # Err (HttpErr (BadStatus { code: 404, body: _ })) ->
        Err (HttpErr (BadStatus 404)) ->
            NotFound |> Task.ok

        Err err ->
            err |> toWebDriverError |> Task.err

## Set browser window position and size.
##
## `x` - x position
## `y` - y position
## `width` - width
## `height` - height
##
## All parameters are optional.
##
## ```
## browser |> Browser.setWindowRect! {
##     x: Value 0,
##     y: Value 0,
## }
## ```
## ```
## browser |> Browser.setWindowRect! {
##     width: Value 100,
##     height: Value 100,
##     x: None,
## }
## ```
setWindowRect : Browser, WebDriver.SetWindowRectPayload -> Task.Task {} [WebDriverError Str]
setWindowRect = \browser, rect ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser
    _ =
        WebDriver.setWindowRect serverUrl sessionId rect
            |> Task.mapErr! toWebDriverError

    {} |> Task.ok

## Set browser window size.
##
## `width` - width
## `height` - height
##
## ```
## # set size 100x800
## browser |> Browser.setSize! 100 800
## ```
setSize : Browser, I32, I32 -> Task.Task {} [WebDriverError Str]
setSize = \browser, width, height ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser
    _ =
        WebDriver.setWindowRect serverUrl sessionId { width: Some width, height: Some height }
            |> Task.mapErr! toWebDriverError

    {} |> Task.ok

## Move the browser window to new x,y coordinates.
##
## `x` - x
## `y` - y
##
## ```
## # move to 100x800
## browser |> Browser.moveTo! 100 800
## ```
moveTo : Browser, I32, I32 -> Task.Task {} [WebDriverError Str]
moveTo = \browser, x, y ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser
    _ =
        WebDriver.setWindowRect serverUrl sessionId { x: Some x, y: Some y }
            |> Task.mapErr! toWebDriverError

    {} |> Task.ok

## Get browser title.
##
## ```
## browser |> Browser.navigateTo! "http://google.com"
## # get title
## title = browser |> Browser.getTitle!
## # title = "Google"
## ```
getTitle : Browser -> Task.Task Str [WebDriverError Str]
getTitle = \browser ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser
    WebDriver.getWindowTitle serverUrl sessionId
        |> Task.mapErr! toWebDriverError

## Get current URL.
##
## ```
## browser |> Browser.navigateTo! "http://google.com"
## # get url
## url = browser |> Browser.getUrl!
## # url = "https://google.com/"
## ```
getUrl : Browser -> Task.Task Str [WebDriverError Str]
getUrl = \browser ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser
    WebDriver.getUrl serverUrl sessionId
        |> Task.mapErr! toWebDriverError

## Navigate back in the browser history.
##
## ```
## browser |> Browser.navigateBack!
## ```
navigateBack : Browser -> Task.Task {} [WebDriverError Str]
navigateBack = \browser ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser
    _ =
        WebDriver.navigateBack serverUrl sessionId
            |> Task.mapErr! toWebDriverError

    Task.ok {}

## Navigate forward in the browser history.
##
## ```
## browser |> Browser.navigateForward!
## ```
navigateForward : Browser -> Task.Task {} [WebDriverError Str]
navigateForward = \browser ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser
    _ =
        WebDriver.navigateForward serverUrl sessionId
            |> Task.mapErr! toWebDriverError

    Task.ok {}

## Reload the current page.
##
## ```
## browser |> Browser.reloadPage!
## ```
reloadPage : Browser -> Task.Task {} [WebDriverError Str]
reloadPage = \browser ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser
    _ =
        WebDriver.reloadPage serverUrl sessionId
            |> Task.mapErr! toWebDriverError

    Task.ok {}

## Maximize the `Browser` window.
##
## ```
## browser |> Browser.maximizeWindow!
## ```
maximizeWindow : Browser -> Task.Task WebDriver.WindowRectResponseValue [WebDriverError Str]
maximizeWindow = \browser ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser
    WebDriver.maximizeWindow serverUrl sessionId
    |> Task.mapErr toWebDriverError

## Minimize the `Browser` window.
##
## ```
## browser |> Browser.minimizeWindow!
## ```
minimizeWindow : Browser -> Task.Task WebDriver.WindowRectResponseValue [WebDriverError Str]
minimizeWindow = \browser ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser
    WebDriver.minimizeWindow serverUrl sessionId
    |> Task.mapErr toWebDriverError

## Make the `Browser` window full screen.
##
## ```
## browser |> Browser.fullScreenWindow!
## ```
fullScreenWindow : Browser -> Task.Task WebDriver.WindowRectResponseValue [WebDriverError Str]
fullScreenWindow = \browser ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser
    WebDriver.fullScreenWindow serverUrl sessionId
    |> Task.mapErr toWebDriverError

## Print current page to PDF.
##
## The result will be **base64** encoded `Str`.
##
## ```
## base64PdfStr = browser |> Browser.printPdfBase64! {}
## ```
printPdfBase64 : Browser, WebDriver.PrintPdfPayload -> Task.Task Str [WebDriverError Str]
printPdfBase64 = \browser, options ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser

    WebDriver.printPdf serverUrl sessionId options
    |> Task.mapErr toWebDriverError

## Print current page to PDF.
##
## The result will be a `List U8`.
##
## ```
## bytes = browser |> Browser.printPdf! {}
## ```
printPdf : Browser, WebDriver.PrintPdfPayload -> Task.Task (List U8) [WebDriverError Str]
printPdf = \browser, options ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser

    WebDriver.printPdf serverUrl sessionId options
    |> Task.map \value -> value |> Base64.decodeStr
    |> Task.mapErr toWebDriverError

## Take a screenshot of the whole document.
##
## The result will be a **base64** encoded `Str` representation of a PNG file.
##
## ```
## base64PngStr = browser |> Browser.getScreenshotBase64!
## ```
getScreenshotBase64 : Browser -> Task.Task Str [WebDriverError Str]
getScreenshotBase64 = \browser ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser

    WebDriver.takeWindowScreenshot serverUrl sessionId
    |> Task.mapErr toWebDriverError

## Take a screenshot of the whole document.
##
## The result will be a **base64** encoded `List U8` representation of a PNG file.
##
## ```
## pngBytes = browser |> Browser.getScreenshot!
## ```
getScreenshot : Browser -> Task.Task (List U8) [WebDriverError Str]
getScreenshot = \browser ->
    { sessionId, serverUrl } = Internal.unpackBrowserData browser

    WebDriver.takeWindowScreenshot serverUrl sessionId
    |> Task.map \value -> value |> Base64.decodeStr
    |> Task.mapErr toWebDriverError

