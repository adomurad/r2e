## `Assert` module contains assertion functions to check properties of` Elements`
## and data extracted from the browser.
##
## All assert function return a `Task` with the `[AssertionError Str]` error.
module [shouldBe]

import pf.Task

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
shouldBe = \expected, actual ->
    if expected == actual then
        Task.ok {}
    else
        Task.err (AssertionError "Expected \"$(expected)\" to be \"$(actual)\"")
