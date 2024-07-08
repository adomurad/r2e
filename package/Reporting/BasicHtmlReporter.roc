## `Report` module contains test reporters.
module [reporter]

import pf.Task exposing [Task]
import Reporting

reporter = Reporting.createReporter "basicHtmlReporter" \_results ->
    lenStr = "6"
    [{ filePath: "index.html", content: "<h3>wow failed: $(lenStr)</h3>" }]

