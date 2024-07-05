app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.11.0/SY4WWMhWQ9NvQgvIthcv15AUeA7rAIJHAHgiaSHGhdY.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.10.0/KbIfTNbxShRX1A1FgXei1SpO5Jn8sgP6HP6PXbi-xyA.tar.br",
    r2e: "../package/main.roc",
}

import pf.Stdout
import pf.Task
import r2e.Browser
import r2e.Element
import r2e.Test exposing [test]
import r2e.Assert

main : Task.Task {} _
main =
    tests = [
        test1,
        test2,
        test3,
        test4,
        test5,
        test6,
        test7,
        test8,
        test9,
        test10,
        test11,
        test12,
        test13,
        test14,
        test15,
        test16,
        test17,
        test18,
        test19,
    ]

    results = tests |> Test.runAllTests! {}
    results |> Test.getResultCode

test1 = test "Find by Css" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    button = browser |> Browser.findElement! (Css "#submit-button")
    buttonText = button |> Element.getText!
    Stdout.line! "Button text is: $(buttonText)"

test2 = test "Find by XPath" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    button = browser |> Browser.findElement! (XPath "//*[@id=\"submit-button\"]")
    buttonText = button |> Element.getText!
    Stdout.line! "Button text is: $(buttonText)"

test3 = test "Find by TestId" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    button = browser |> Browser.findElement! (TestId "populate-button")
    buttonText = button |> Element.getText!
    # TODO getValue
    Stdout.line! "Button text is: $(buttonText)"

test4 = test "Try find element - Found" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    maybeButton = browser |> Browser.tryFindElement! (Css "#submit-button")

    when maybeButton is
        NotFound -> Stdout.line! "Button not found"
        Found el ->
            buttonText = el |> Element.getText!
            Stdout.line! "Button found with text: $(buttonText)"

test5 = test "Try find element - NotFound" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    maybeButton = browser |> Browser.tryFindElement! (Css "#fake-id-fake-abcd")

    when maybeButton is
        NotFound -> Stdout.line! "Button not found"
        Found el ->
            buttonText = el |> Element.getText!
            Stdout.line! "Button found with text: $(buttonText)"

test6 = test "Find many elements" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    optionElements = browser |> Browser.findElements! (Css "option")
    optionElements |> List.len |> Num.toStr |> Assert.shouldBe "3"

test7 = test "Get title" \browser ->
    browser |> Browser.navigateTo! "http://google.com"
    title = browser |> Browser.getTitle!
    title |> Assert.shouldBe "Google"

test8 = test "Get url" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    url = browser |> Browser.getUrl!
    url |> Assert.shouldBe "https://devexpress.github.io/testcafe/example/"

test9 = test "Navigate back and forth" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    browser |> Assert.urlShouldBe! "https://devexpress.github.io/testcafe/example/"
    browser |> Browser.navigateTo! "https://roc-lang.org"
    browser |> Assert.urlShouldBe! "https://www.roc-lang.org/"
    browser |> Browser.navigateBack!
    browser |> Assert.urlShouldBe! "https://devexpress.github.io/testcafe/example/"
    browser |> Browser.navigateForward!
    browser |> Assert.urlShouldBe! "https://www.roc-lang.org/"

test10 = test "Reload page and assert title" \browser ->
    browser |> Browser.navigateTo! "http://google.com"
    browser |> Assert.titleShouldBe! "Google"
    browser |> Browser.reloadPage!
    browser |> Assert.titleShouldBe! "Google"

test11 = test "Maximize, minimize, go full screen" \browser ->
    browser |> Browser.navigateTo! "http://google.com"
    { width } = browser |> Browser.maximizeWindow!
    width |> Assert.shouldBeGreaterThan! 0
    browser |> Browser.minimizeWindow!
    _ = browser |> Browser.fullScreenWindow!
    Task.ok {}

test12 = test "Asserts" \_ ->
    1 |> Assert.shouldBeGreaterThan! 0
    1 |> Assert.shouldBeGreaterOrEqualTo! 1
    2 |> Assert.shouldBeGreaterOrEqualTo! 1
    4 |> Assert.shouldBeLesserThan! 5
    5 |> Assert.shouldBeLesserOrEqualTo! 5
    4 |> Assert.shouldBeLesserOrEqualTo! 5
    5 |> Assert.shouldBe! 5

test13 = test "Type and clear input" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    nameInput = browser |> Browser.findElement! (Css "#developer-name")
    nameInputValue1 = nameInput |> Element.getValue!
    nameInputValue1 |> Assert.shouldBe! ""
    nameInput |> Element.sendKeys! "test"
    nameInputValue2 = nameInput |> Element.getValue!
    nameInputValue2 |> Assert.shouldBe! "test"
    nameInput |> Element.clear!
    nameInputValue3 = nameInput |> Element.getValue!
    nameInputValue3 |> Assert.shouldBe ""

test14 = test "getAttribute" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    nameInput = browser |> Browser.findElement! (Css "#developer-name")
    inputType = nameInput |> Element.getAttribute! "type"
    when inputType is
        Ok value -> value |> Assert.shouldBe "text" # <input type="text" ...
        Err Empty -> Assert.failWith "this should not happen"

test15 = test "getAttribute Empty" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    nameInput = browser |> Browser.findElement! (Css "#developer-name")
    inputType = nameInput |> Element.getAttribute! "fake-attribute"
    when inputType is
        Ok _ -> Assert.failWith "this should be empty"
        Err Empty -> Task.ok {}

test16 = test "getProperty str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    nameInput = browser |> Browser.findElement! (Css "#developer-name")
    nameInput |> Element.sendKeys! "my name"
    inputType = nameInput |> Element.getProperty! "value"
    when inputType is
        Ok value -> value |> Assert.shouldBe "my name"
        Err Empty -> Assert.failWith "this should not happen"

test17 = test "getProperty Empty" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    nameInput = browser |> Browser.findElement! (Css "#developer-name")
    nameInput |> Element.sendKeys! "my name"
    inputType = nameInput |> Element.getProperty! "fakeProp"
    when inputType is
        Ok _ -> Assert.failWith "this should be empty"
        Err Empty -> Task.ok {}

test18 = test "getProperty bool" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    nameInput = browser |> Browser.findElement! (Css "#developer-name")
    nameInput |> Element.sendKeys! "my name"
    inputType = nameInput |> Element.getProperty! "checked"
    when inputType is
        Ok value -> value |> Assert.shouldBe Bool.false
        Err Empty -> Assert.failWith "this should not happen"

test19 = test "getProperty int" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    nameInput = browser |> Browser.findElement! (Css "#developer-name")
    nameInput |> Element.sendKeys! "my name"
    inputType = nameInput |> Element.getProperty! "clientHeight"
    inputType |> Assert.shouldBe (Ok 17)

