app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.12.0/cf_TpThUd4e69C7WzHxCbgsagnDmk3xlb_HmEKXTICw.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.10.0/KbIfTNbxShRX1A1FgXei1SpO5Jn8sgP6HP6PXbi-xyA.tar.br",
    r2e: "../package/main.roc",
}

import pf.Task
import r2e.Browser
import r2e.Test exposing [test]
import pf.File

main : Task.Task {} _
main =
    tests = [
        test1,
        test2,
        test3,
        test4,
    ]

    Test.runAllTests tests {}

# TODO - missing base64 -> List U8

test1 = test "Default PDF" \browser ->
    browser |> Browser.navigateTo! "https://roc-lang.org/"
    base64PdfStr = browser |> Browser.printPdfBase64! {}
    File.writeUtf8! "default.base64.txt" base64PdfStr

test2 = test "Custom PDF" \browser ->
    browser |> Browser.navigateTo! "https://roc-lang.org/"
    base64PdfStr =
        browser
            |> Browser.printPdfBase64! {
                page: { width: 15, height: 15 },
                margin: {
                    top: 0.5,
                    bottom: 0,
                    left: 0,
                    right: 0,
                },
                scale: 2.0,
                orientation: Portrait,
                shrinkToFit: Bool.true,
                background: Bool.true,
                pageRanges: [],
            }
    File.writeUtf8! "custom.base64.txt" base64PdfStr

test3 = test "Browser screenshot" \browser ->
    browser |> Browser.navigateTo! "https://roc-lang.org/"
    base64PngStr = browser |> Browser.getScreenshotBase64!
    File.writeUtf8! "browser.png.base64" base64PngStr

test4 = test "Element screenshot" \browser ->
    browser |> Browser.navigateTo! "https://roc-lang.org/"
    logo = browser |> Browser.findElement! (Css "#homepage-logo")
    base64PngStr = logo |> Element.getScreenshotBase64!
    File.writeUtf8! "logo.png.base64" base64PngStr

