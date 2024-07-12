## `Driver` module contains function for creating and configuring the
## webdriver client connection.
##
## The `Driver` is needed to interact with the webdriver server.
module [
    create,
    Connection,
    DriverConfiguration,
]

import pf.Task
import Internal

# ----------------------------------------------------------------

getDriverUrl : Connection -> Str
getDriverUrl = \config ->
    # TODO port and host validation
    when config is
        LocalServerWithDefaultPort -> "http://localhost:9515"
        LocalServer port ->
            portStr = port |> Num.toStr
            "http://localhost:$(portStr)"

        RemoteServer host -> host

# ----------------------------------------------------------------

##  Driver configuration object
##
## `connection` - configure driver url, default = LocalServerWithDefaultPort
##
DriverConfiguration : {
    connection ? Connection,
    headless ? Bool,
    acceptInsecureCerts ? Bool,
}

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
create : DriverConfiguration -> Internal.Driver
create = \{ connection ? LocalServerWithDefaultPort, headless ? Bool.false, acceptInsecureCerts ? Bool.true } ->
    serverUrl = getDriverUrl connection
    Internal.packDriverData { serverUrl, headless, acceptInsecureCerts }

