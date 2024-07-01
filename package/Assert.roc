## `Assert` module contains assertion functions to check properties of` Elements`
## and data extracted from the browser.
##
## All assert function return a `Task` with the `[AssertionError Str]` error.
module [shouldBe, urlShouldBe, titleShouldBe]

import pf.Task
import Internal exposing [Browser]
import Browser

## Checks if the __actual__ `Str` is equal to the __expected__.
##
## ```
## # find button element
## button = browser |> Browser.findElement! (Css "#submit-button")
## # get button text
## buttonText = button |> Element.getText!
## # assert text
## buttonText |> Assert.shouldBe! "Roc"
## ```
shouldBe : Str, Str -> Task.Task {} [AssertionError Str]
shouldBe = \actual, expected ->
    if expected == actual then
        Task.ok {}
    else
        Task.err (AssertionError "Expected \"$(actual)\" to be \"$(expected)\"")

## Checks if the __URL__ is equal to the __expected__.
##
## ```
## # assert text
## browser |> Assert.urlShouldBe! "https://roc-lang.org/"
## ```
urlShouldBe : Browser, Str -> Task.Task {} [AssertionError Str, WebDriverError Str]
urlShouldBe = \browser, expected ->
    actual = browser |> Browser.getUrl!

    if expected == actual then
        Task.ok {}
    else
        Task.err (AssertionError "Expected URL \"$(actual)\" to be \"$(expected)\"")

## Checks if the __title__ of the page is equal to the __expected__.
##
## ```
## # assert text
## browser |> Assert.urlShouldBe! "https://roc-lang.org/"
## ```
titleShouldBe : Browser, Str -> Task.Task {} [AssertionError Str, WebDriverError Str]
titleShouldBe = \browser, expected ->
    actual = browser |> Browser.getTitle!

    if expected == actual then
        Task.ok {}
    else
        Task.err (AssertionError "Expected page title \"$(actual)\" to be \"$(expected)\"")
