module [
    checkStatus,
    startSession,
    deleteSession,
    findElement,
    findElements,
    getElementText,
    getElementAttribute,
    getElementProperty,
    clickElement,
    navigateTo,
    getLocator,
    sendKeys,
    setWindowRect,
    SetWindowRectPayload,
    LocatorStrategy,
    getWindowTitle,
    getUrl,
    navigateBack,
    navigateForward,
    reloadPage,
    maximizeWindow,
    minimizeWindow,
    fullScreenWindow,
    WindowRectResponseValue,
    printPdf,
    PrintPdfPayload,
    clearElement,
    takeElementScreenshot,
    takeWindowScreenshot,
]

# import pf.Stdout
import pf.Http exposing [TimeoutConfig]
import pf.Task
import json.Json
import json.OptionOrNull exposing [OptionOrNull]
import json.Option

# ----------------------------------------------------------------

LocatorStrategy : [
    Css Str,
    LinkTextSelector Str,
    PartialLinkTextSelector Str,
    Tag Str,
    XPath Str,
]

getLocator : LocatorStrategy -> (Str, Str)
getLocator = \locator ->
    when locator is
        Css cssSelector -> ("css selector", cssSelector)
        LinkTextSelector text -> ("link text", text)
        PartialLinkTextSelector text -> ("partial link text", text)
        Tag tag -> ("tag name", tag)
        XPath path -> ("xpath", path)

# ----------------------------------------------------------------

CheckStatusResponse : {
    value : {
        build : {
            version : Str,
        },
        message : Str,
        os : {
            arch : Str,
            name : Str,
            version : Str,
        },
        ready : Bool,
    },
}

## Check WebDriver status
##
checkStatus : Str -> Task.Task CheckStatusResponse _
checkStatus = \host ->
    request : Task.Task CheckStatusResponse _
    request = sendCommand host Get "/status" []

    result = request!

    Task.ok result

StartSessionPayload : {
    headless ? Bool,
    acceptInsecureCerts ? Bool,
}

StartSessionJsonPayload : {
    capabilities : CapabilitiesJsonPayload,
}

CapabilitiesJsonPayload : {
    alwaysMatch : CapabilitiesSet,
    # firstMatch : List CapabilitiesSet,
}

CapabilitiesSet : {
    acceptInsecureCerts : Bool,
    edgeOptions : BrowserOptions,
    chromeOptions : BrowserOptions,
    firefoxOptions : BrowserOptions,
}

BrowserOptions : {
    args : List Str,
}

StartSessionResponse : {
    value : {
        sessionId : Str,
    },
}

getBrowserOptions = \headless -> {
    args: if headless then
        ["--headless"]
    else
        [],
}

jsonWebdriverMapping = \key ->
    when key is
        "edgeOptions" -> "ms:edgeOptions"
        "chromeOptions" -> "goog:chromeOptions"
        "firefoxOptions" -> "moz:firefoxOptions"
        k -> k

startSession : Str, StartSessionPayload -> Task.Task Str _
startSession = \host, { headless ? Bool.false, acceptInsecureCerts ? Bool.false } ->
    payloadObj : StartSessionJsonPayload
    payloadObj = {
        capabilities: {
            alwaysMatch: {
                acceptInsecureCerts,
                edgeOptions: getBrowserOptions headless,
                chromeOptions: getBrowserOptions headless,
                firefoxOptions: getBrowserOptions headless,
            },
            # firstMatch: [],
        },
    }

    payload = Encode.toBytes payloadObj (Json.utf8With { fieldNameMapping: Custom jsonWebdriverMapping })

    request : Task.Task StartSessionResponse _
    request = sendCommand host Post "/session" payload

    result = request!

    Task.ok "$(result.value.sessionId)"

deleteSession : Str, Str -> Task.Task {} _
deleteSession = \host, sessionId ->
    request : Task.Task {} _
    request = sendCommand host Delete "/session/$(sessionId)" []

    _ = request!

    Task.ok {}

navigateTo : Str, Str, Str -> Task.Task {} _
navigateTo = \host, sessionId, url ->
    payload = "{\"url\": \"$(url)\"}" |> Str.toUtf8

    request : Task.Task {} _
    request = sendCommand host Post "/session/$(sessionId)/url" payload

    _ = request!

    Task.ok {}

FindElementPayload : {
    using : Str,
    value : Str,
}

FindElementResponse : {
    value : {
        element606611e4a52e4f735466cecf : Str,
    },
}

findElement : Str, Str, LocatorStrategy -> Task.Task Str _
findElement = \host, sessionId, locator ->
    (locatorStrategy, locatorValue) = getLocator locator

    payloadObj : FindElementPayload
    payloadObj = {
        using: locatorStrategy,
        value: locatorValue,
    }

    payload = Encode.toBytes payloadObj Json.utf8

    request : Task.Task FindElementResponse _
    request = sendCommand host Post "/session/$(sessionId)/element" payload

    result = request!

    Task.ok result.value.element606611e4a52e4f735466cecf

FindElementsResponse : {
    value : List {
        element606611e4a52e4f735466cecf : Str,
    },
}

findElements : Str, Str, LocatorStrategy -> Task.Task (List Str) _
findElements = \host, sessionId, locator ->
    (locatorStrategy, locatorValue) = getLocator locator

    payloadObj : FindElementPayload
    payloadObj = {
        using: locatorStrategy,
        value: locatorValue,
    }

    payload = Encode.toBytes payloadObj Json.utf8

    request : Task.Task FindElementsResponse _
    request = sendCommand host Post "/session/$(sessionId)/elements" payload

    result = request!

    elementList = result.value |> List.map .element606611e4a52e4f735466cecf

    Task.ok elementList

clickElement : Str, Str, Str -> Task.Task {} _
clickElement = \host, sessionId, elementId ->
    payload = "{}" |> Str.toUtf8

    request : Task.Task {} _
    request = sendCommand host Post "/session/$(sessionId)/element/$(elementId)/click" payload

    _ = request!

    Task.ok {}

clearElement : Str, Str, Str -> Task.Task {} _
clearElement = \host, sessionId, elementId ->
    payload = "{}" |> Str.toUtf8

    request : Task.Task {} _
    request = sendCommand host Post "/session/$(sessionId)/element/$(elementId)/clear" payload

    _ = request!

    Task.ok {}

GetElementTextResponse : {
    value : Str,
}

getElementText : Str, Str, Str -> Task.Task Str _
getElementText = \host, sessionId, elementId ->
    request : Task.Task GetElementTextResponse _
    request = sendCommand host Get "/session/$(sessionId)/element/$(elementId)/text" []

    result = request!

    Task.ok result.value

GetElementAttributeResponse : {
    value : Option.Option Str,
}

getElementAttribute : Str, Str, Str, Str -> Task.Task (Result Str [Empty]) _
getElementAttribute = \host, sessionId, elementId, attributeName ->
    request : Task.Task GetElementAttributeResponse _
    request = sendCommand host Get "/session/$(sessionId)/element/$(elementId)/attribute/$(attributeName)" []

    result = request!

    optionValue = Option.get result.value

    when optionValue is
        Some val -> Task.ok (Ok val)
        None -> Task.ok (Err Empty)

GetElementPropertyResponse a : {
    value : Option.Option a,
}

getElementProperty : Str, Str, Str, Str -> Task.Task (Result a [Empty]) _
getElementProperty = \host, sessionId, elementId, propertyName ->
    request : Task.Task (GetElementPropertyResponse a) _
    request = sendCommand host Get "/session/$(sessionId)/element/$(elementId)/property/$(propertyName)" []

    result = request!

    optionValue = Option.get result.value

    when optionValue is
        Some val -> Task.ok (Ok val)
        None -> Task.ok (Err Empty)

# SendKeysPayload : {
#     text : Str,
# }

sendKeys : Str, Str, Str, Str -> Task.Task {} _
sendKeys = \host, sessionId, elementId, str ->
    # payloadObj : SendKeysPayload
    # payloadObj = {
    #     text: str,
    # }

    # do not escape - codes like "\\uE007" will not work
    # TODO
    payload = "{\"text\":\"$(str)\"}" |> Str.toUtf8

    request : Task.Task {} _
    request = sendCommand host Post "/session/$(sessionId)/element/$(elementId)/value" payload

    _ = request!

    Task.ok {}

Option a : [Some a, None]

mapNullableToJsonWithNull : Option a -> OptionOrNull a
mapNullableToJsonWithNull = \val ->
    when val is
        None -> OptionOrNull.null {}
        Some a -> OptionOrNull.some a

SetWindowRectPayload : {
    x ? Option I32,
    y ? Option I32,
    width ? Option I32,
    height ? Option I32,
}

SetWindowRectJsonPayload : {
    x : OptionOrNull I32,
    y : OptionOrNull I32,
    width : OptionOrNull I32,
    height : OptionOrNull I32,
}

SetWindowRectResponse : {
    value : SetWindowRectJsonPayload,
}

setWindowRect : Str, Str, SetWindowRectPayload -> Task.Task SetWindowRectJsonPayload _
setWindowRect = \host, sessionId, { x ? None, y ? None, width ? None, height ? None } ->
    payloadObj : SetWindowRectJsonPayload
    payloadObj = {
        x: x |> mapNullableToJsonWithNull,
        y: y |> mapNullableToJsonWithNull,
        width: width |> mapNullableToJsonWithNull,
        height: height |> mapNullableToJsonWithNull,
    }

    payload = Encode.toBytes payloadObj Json.utf8

    request : Task.Task SetWindowRectResponse _
    request = sendCommand host Post "/session/$(sessionId)/window/rect" payload

    result = request!

    Task.ok result.value

GetWindowTitleResponse : {
    value : Str,
}

getWindowTitle : Str, Str -> Task.Task Str _
getWindowTitle = \host, sessionId ->
    request : Task.Task GetWindowTitleResponse _
    request = sendCommand host Get "/session/$(sessionId)/title" []

    result = request!

    Task.ok result.value

GetUrlResponse : {
    value : Str,
}

getUrl : Str, Str -> Task.Task Str _
getUrl = \host, sessionId ->
    request : Task.Task GetUrlResponse _
    request = sendCommand host Get "/session/$(sessionId)/url" []

    result = request!

    Task.ok result.value

navigateBack : Str, Str -> Task.Task {} _
navigateBack = \host, sessionId ->
    payload = "{}" |> Str.toUtf8

    request : Task.Task {} _
    request = sendCommand host Post "/session/$(sessionId)/back" payload

    _ = request!

    Task.ok {}

navigateForward : Str, Str -> Task.Task {} _
navigateForward = \host, sessionId ->
    payload = "{}" |> Str.toUtf8

    request : Task.Task {} _
    request = sendCommand host Post "/session/$(sessionId)/forward" payload

    _ = request!

    Task.ok {}

reloadPage : Str, Str -> Task.Task {} _
reloadPage = \host, sessionId ->
    payload = "{}" |> Str.toUtf8

    request : Task.Task {} _
    request = sendCommand host Post "/session/$(sessionId)/refresh" payload

    _ = request!

    Task.ok {}

WindowRectResponseValue : {
    x : I32,
    y : I32,
    width : I32,
    height : I32,
}

WindowRectResponse : {
    value : WindowRectResponseValue,
}

maximizeWindow : Str, Str -> Task.Task WindowRectResponseValue _
maximizeWindow = \host, sessionId ->
    payload = "{}" |> Str.toUtf8

    request : Task.Task WindowRectResponse _
    request = sendCommand host Post "/session/$(sessionId)/window/maximize" payload

    response = request!

    Task.ok response.value

minimizeWindow : Str, Str -> Task.Task WindowRectResponseValue _
minimizeWindow = \host, sessionId ->
    payload = "{}" |> Str.toUtf8

    request : Task.Task WindowRectResponse _
    request = sendCommand host Post "/session/$(sessionId)/window/minimize" payload

    response = request!

    Task.ok response.value

fullScreenWindow : Str, Str -> Task.Task WindowRectResponseValue _
fullScreenWindow = \host, sessionId ->
    payload = "{}" |> Str.toUtf8

    request : Task.Task WindowRectResponse _
    request = sendCommand host Post "/session/$(sessionId)/window/fullscreen" payload

    response = request!

    Task.ok response.value

PageOrientation : [Landscape, Portrait]

PrintPdfPayload : {
    page ? PageDimensions,
    margin ? PageMargins,
    scale ? F32, # 0.1 - 2.0 - default: 1.0
    orientation ? PageOrientation, # default: portrait
    shrinkToFit ? Bool, # default: true
    background ? Bool, # default: false
    pageRanges ? List Str, # default []
}

PageDimensions : {
    width : F32, # default: 21.59 cm
    height : F32, # default: 27.94 cm
}

PageMargins : {
    top : F32, # default: 1 cm
    bottom : F32, # default: 1 cm
    left : F32, # default: 1 cm
    right : F32, # default: 1 cm
}

PrintPdfJsonPayload : {
    page : PageDimensions,
    margin : PageMargins,
    scale : F32,
    orientation : Str,
    shrinkToFit : Bool,
    background : Bool,
    pageRanges : List Str,
}

# PrintPdfResponse : {
#     value : Str,
# }

printPdf : Str, Str, PrintPdfPayload -> Task.Task Str _
printPdf = \host, sessionId, { scale ? 1.0f32, orientation ? Portrait, shrinkToFit ? Bool.true, background ? Bool.false, page ? { width: 21.59f32, height: 27.94f32 }, margin ? { top: 1.0f32, bottom: 1.0f32, left: 1.0f32, right: 1.0f32 }, pageRanges ? [] } ->
    payloadObj : PrintPdfJsonPayload
    payloadObj = {
        page,
        margin,
        scale,
        orientation: if orientation == Portrait then "portrait" else "landcape",
        shrinkToFit,
        background,
        pageRanges,
    }

    payload = Encode.toBytes payloadObj Json.utf8

    # request : Task.Task PrintPdfResponse _
    request = sendCommandWithBase64Response host Post "/session/$(sessionId)/print" payload

    result = request!

    Task.ok result

# ScreenshotResponse : {
#     value : Str,
# }

takeWindowScreenshot : Str, Str -> Task.Task Str _
takeWindowScreenshot = \host, sessionId ->
    # request : Task.Task ScreenshotResponse _
    # temporary - json decoding cannot decode strings above 170 000 chars
    request = sendCommandWithBase64Response host Get "/session/$(sessionId)/screenshot" []

    result = request!

    Task.ok result

takeElementScreenshot : Str, Str, Str -> Task.Task Str _
takeElementScreenshot = \host, sessionId, elementId ->
    # request : Task.Task ScreenshotResponse _
    # temporary - json decoding cannot decode strings above 170 000 chars
    request = sendCommandWithBase64Response host Get "/session/$(sessionId)/element/$(elementId)/screenshot" []

    result = request!

    Task.ok result

# ---------------------------------

timeoutConfig : TimeoutConfig
timeoutConfig = TimeoutMilliseconds 30000

sendCommand = \host, method, path, body ->
    # bodyObj = body |> Str.toUtf8
    headers = [
        Http.header "Content-Type" "application/json",
    ]

    result <-
        { Http.defaultRequest &
            url: "$(host)$(path)",
            method,
            body: body,
            headers,
            timeout: timeoutConfig,
        }
        |> Http.send
        |> Task.attempt

    when result is
        Ok response ->
            # r2 = response.body |> Str.fromUtf8 |> Result.withDefault "fail"
            # _ = Stdout.line "ok: $(r2)" |> Task.result!
            # _ = Stdout.line "ok: $(response.statusText)" |> Task.result!
            decodeResponse response.body

        Err err ->
            # _ = Stdout.line "error" |> Task.result!
            # {} <- await (logError err)
            Task.err err

removeSpecialChars = \str ->
    str |> Str.split "-" |> Str.joinWith ""

decoder = Json.utf8With { fieldNameMapping: Custom removeSpecialChars }

decodeResponse = \responseBody ->
    decoded = Decode.fromBytesPartial responseBody decoder

    decoded.result |> Task.fromResult |> Task.mapErr JsonParsingError

# TODO
# temporary - json decoding cannot decode strings above 170 000 chars
extractBase64ValueFromResponse = \str ->
    isStartOk = str |> List.startsWith (Str.toUtf8 "{\"value\":\"")
    isEndOk = str |> List.endsWith (Str.toUtf8 "\"}")
    if isStartOk && isEndOk then
        str |> List.dropFirst 10 |> List.dropLast 2 |> Str.fromUtf8
    else
        Err DecodingError

# TODO
# temporary - json decoding cannot decode strings above 170 000 chars
sendCommandWithBase64Response = \host, method, path, body ->
    headers = [
        Http.header "Content-Type" "application/json",
    ]

    result <-
        { Http.defaultRequest &
            url: "$(host)$(path)",
            method,
            body: body,
            headers,
            timeout: timeoutConfig,
        }
        |> Http.send
        |> Task.attempt

    when result is
        Ok response ->
            response.body |> extractBase64ValueFromResponse |> Task.fromResult |> Task.mapErr \_ -> JsonParsingError DecodeError

        Err err ->
            Task.err err
