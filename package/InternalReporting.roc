## `Report` module contains test reporters.
module [runReporters, ReporterCallback, ReporterDefinition]

import pf.Task exposing [Task]
import pf.Dir
import pf.Path
import pf.File

TestRunResult : {
    name : Str,
    result : Result {} [ErrorMsg Str, ErrorMsgWithScreenshot Str Str],
}

ReporterCallback : List TestRunResult -> List { filePath : Str, content : Str }

ReporterDefinition : {
    name : Str,
    callback : ReporterCallback,
}

runReporters : List ReporterDefinition, List TestRunResult, Str -> Task {} _
runReporters = \reporters, results, outDir ->
    reporters
    |> Task.forEach \reporter ->
        reporter |> runReporter results outDir

runReporter : ReporterDefinition, List TestRunResult, Str -> Task {} _
runReporter = \reporter, results, outDir ->
    dirExists = outDir |> Path.fromStr |> Path.isDir |> Task.result! |> Result.withDefault Bool.false
    createDirIfNoExists =
        if dirExists then
            Task.ok {}
        else
            Dir.createAll outDir
    createDirIfNoExists!

    cb = reporter.callback
    readyFiles = cb results
    readyFiles
        |> Task.forEach! \{ filePath, content } ->
            reporterDirName = reporter.name |> Str.replaceEach "/" "_"
            reporterDir = joinPath outDir reporterDirName
            finalPath = joinPath reporterDir filePath
            createDirForFilePath! finalPath
            File.writeUtf8! finalPath content

    Task.ok {}

joinPath = \path, filename ->
    sanitizedPath = path |> removeTrailing "/"

    "$(sanitizedPath)/$(filename)"

createDirForFilePath = \path ->
    { before } = path |> Str.splitLast "/" |> Task.fromResult!
    Dir.createAll! before

removeTrailing = \outDir, tail ->
    shouldRemove = outDir |> Str.endsWith tail
    if shouldRemove then
        outDir |> Str.replaceLast tail ""
    else
        outDir
