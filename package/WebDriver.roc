module [
    checkStatus,
    startSession,
    deleteSession,
    findElement,
    getElementText,
    clickElement,
    navigateTo,
    getLocator,
    LocatorStrategy,
]

# import pf.Stdout
import pf.Http
import pf.Task
import json.Json

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
    request = sendCommand host Get "/status" ""

    result = request!

    Task.ok result

StartSessionResponse : {
    value : {
        sessionId : Str,
    },
}

startSession : Str -> Task.Task Str _
startSession = \host ->
    request : Task.Task StartSessionResponse _
    request = sendCommand host Post "/session" "{\"capabilities\": {}}"

    result = request!

    Task.ok "$(result.value.sessionId)"

deleteSession : Str, Str -> Task.Task {} _
deleteSession = \host, sessionId ->
    request : Task.Task {} _
    request = sendCommand host Delete "/session/$(sessionId)" ""

    _ = request!

    Task.ok {}

navigateTo : Str, Str, Str -> Task.Task {} _
navigateTo = \host, sessionId, url ->
    request : Task.Task {} _
    request = sendCommand host Post "/session/$(sessionId)/url" "{\"url\": \"$(url)\"}"

    _ = request!

    Task.ok {}

FindElementResponse : {
    value : {
        element606611e4a52e4f735466cecf : Str,
    },
}

findElement : Str, Str, LocatorStrategy -> Task.Task Str _
findElement = \host, sessionId, locator ->
    (locatoryStrategy, locatorValue) = getLocator locator

    request : Task.Task FindElementResponse _
    request = sendCommand host Post "/session/$(sessionId)/element" "{\"using\": \"$(locatoryStrategy)\", \"value\": \"$(locatorValue)\"}"

    result = request!

    Task.ok result.value.element606611e4a52e4f735466cecf

clickElement : Str, Str, Str -> Task.Task {} _
clickElement = \host, sessionId, elementId ->
    request : Task.Task {} _
    request = sendCommand host Post "/session/$(sessionId)/element/$(elementId)/click" "{}"

    _ = request!

    Task.ok {}

GetElementTextResponse : {
    value : Str,
}

getElementText : Str, Str, Str -> Task.Task Str _
getElementText = \host, sessionId, elementId ->
    request : Task.Task GetElementTextResponse _
    request = sendCommand host Get "/session/$(sessionId)/element/$(elementId)/text" ""

    result = request!

    Task.ok result.value

sendCommand = \host, method, path, body ->
    bodyObj = body |> Str.toUtf8
    headers = [
        Http.header "Content-Type" "application/json",
    ]

    result <-
        { Http.defaultRequest &
            url: "$(host)$(path)",
            method,
            body: bodyObj,
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
