module [
    checkStatus,
    startSession,
    deleteSession,
    findElement,
    findElements,
    getElementText,
    clickElement,
    navigateTo,
    getLocator,
    sendKeys,
    setWindowRect,
    SetWindowRectPayload,
    LocatorStrategy,
    getWindowTitle,
    getUrl,
]

# import pf.Stdout
import pf.Http
import pf.Task
import json.Json
import json.OptionOrNull exposing [OptionOrNull]

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

StartSessionResponse : {
    value : {
        sessionId : Str,
    },
}

startSession : Str -> Task.Task Str _
startSession = \host ->
    payload = "{\"capabilities\": {}}" |> Str.toUtf8

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

GetElementTextResponse : {
    value : Str,
}

getElementText : Str, Str, Str -> Task.Task Str _
getElementText = \host, sessionId, elementId ->
    request : Task.Task GetElementTextResponse _
    request = sendCommand host Get "/session/$(sessionId)/element/$(elementId)/text" []

    result = request!

    Task.ok result.value

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

mapNullableToJson : Option a -> OptionOrNull a
mapNullableToJson = \val ->
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
        x: x |> mapNullableToJson,
        y: y |> mapNullableToJson,
        width: width |> mapNullableToJson,
        height: height |> mapNullableToJson,
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
        }
        |> Http.send
        |> Task.attempt

    when result is
        Ok response ->
            decodeResponse response.body

        Err err ->
            # {} <- await (logError err)
            Task.err err

removeSpecialChars = \str ->
    str |> Str.split "-" |> Str.joinWith ""

decoder = Json.utf8With { fieldNameMapping: Custom removeSpecialChars }

decodeResponse = \responseBody ->
    decoded = Decode.fromBytesPartial responseBody decoder

    decoded.result |> Task.fromResult |> Task.mapErr JsonParsingError
