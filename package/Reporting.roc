## `Report` module contains test reporters.
module [createReporter]

import InternalReporting exposing [ReporterCallback, ReporterDefinition]

createReporter : Str, ReporterCallback -> ReporterDefinition
createReporter = \name, callback ->
    { name, callback }

