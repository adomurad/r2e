## `Driver` module contains function for creating and configuring the
## webdriver client connection.
##
## The `Driver` is needed to interact with the webdriver server.
module [
    create,
    Connection,
]

import pf.Task
import Internal

# ----------------------------------------------------------------

getDriverUrl : Connection -> Str
getDriverUrl = \options ->
    # TODO port and host validation
    when options is
        LocalServerWithDefaultPort -> "http://localhost:9515"
        LocalServer port ->
            portStr = port |> Num.toStr
            "http://localhost:$(portStr)"

        RemoteServer host -> host

# ----------------------------------------------------------------

## Connection options for the `Driver`
##
## `LocalServerWithDefaultPort` - "http://localhost:9515"
##
## `LocalServer U8` - localhost with custom port
##
## `RemoteServer Str` - custom url
Connection : [
    LocalServerWithDefaultPort,
    LocalServer U8,
    RemoteServer Str,
]

## Create a `Driver` configuration.
##
## ```
## driver = Driver.create LocalServerWithDefaultPort
## browser = Browser.open! driver "http://google.com"
## ```
##
## ```
## driver = Driver.create (LocalServer 9512)
## browser = Browser.open! driver "http://google.com"
## ```
##
## ```
## driver = Driver.create (RemoteServer "http://localhost:9515")
## browser = Browser.open! driver "http://google.com"
## ```
create : Connection -> Internal.Driver
create = \driverConnection ->
    serverUrl = getDriverUrl driverConnection
    Internal.packDriverData { serverUrl }

