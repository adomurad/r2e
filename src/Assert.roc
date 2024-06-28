module [shouldBe]

import pf.Task

shouldBe : Str, Str -> Task.Task {} [AssertionError Str]
shouldBe = \expected, actual ->
    if expected == actual then
        Task.ok {}
    else
        Task.err (AssertionError "Expected \"$(expected)\" to be \"$(actual)\"")
