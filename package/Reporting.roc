## `Report` module contains test reporters.
module [createReporter, rename]

import InternalReporting exposing [ReporterCallback, ReporterDefinition]

createReporter : Str, ReporterCallback -> ReporterDefinition
createReporter = \name, callback ->
    { name, callback }

rename : ReporterDefinition, Str -> ReporterDefinition
rename = \reporter, newName ->
    { reporter & name: newName }
