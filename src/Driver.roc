module [
    create,
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

Connection : [
    LocalServerWithDefaultPort,
    LocalServer U8,
    RemoteServer Str,
]

create : Connection -> Internal.Driver
create = \driverConnection ->
    serverUrl = getDriverUrl driverConnection
    Internal.packDriverData { serverUrl }

