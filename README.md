# r2e

Roc2End is a toy End2End framework.

This is a library that has to be used with the basic-cli platform!

Maybe you are looking for the
[R2E Platform](https://github.com/adomurad/r2e-platform) ?

[Full Documentation](https://adomurad.github.io/r2e-docs/)

**WARNING: This package is importing modules from platform!** - this will be blocked in future. Waiting for `module params` to refactor this.

So use at your own risk - sooner or later this will stop working.

Current implementation is minimal, and a lot of webdriver features are still missing.

## Demo

![](./r2e-demo.gif)

## Examples

### E2E testing

The `test` wrapper will make sure to cleanup after tests when they fail.

TODO: This will be able to generate a test report in most popular formats.

```elixir
test1 = test "go to google and click some stuff" \browser ->
    # open the page http://google.com in browser
    browser |> Browser.navigateTo! "http://google.com"

    # find the html element with a css selector "#L2AGLb"
    button = browser |> Browser.findElement! (Css "#L2AGLb")

    # get the text of the button
    buttonText = button |> Element.getText!
    Stdout.line! "Button text is: $(buttonText)"

    # assert button text
    buttonText |> Assert.shouldBe! "Accept all"

    # click the button
    button |> Element.click!
```

### Web crawling

You can control the browser outside of tests.

You can open multiple browser windows, etc.

```elixir
main =
    # create a driver client for http://localhost:9515
    driver = Driver.create {}

    # open the page http://google.com in browser
    browser = Browser.open! driver "http://google.com"

    # find the html element with a css selector "#L2AGLb"
    button = browser |> Browser.findElement! (Css "#L2AGLb")

    # get the text of the button
    buttonText = button |> Element.getText!
    Stdout.line! "Button text is: $(buttonText)"

    # click the button
    button |> Element.click!

    # close the browser
    browser |> Browser.close!
```

## Setup

To run examples in [examples/]() you need a running webdriver (msedgedrive, chromedrive, geckodriver, etc.)

Make sure that the webdriver has the same version as your browser. e.g. when using chromedriver 120, your chrome also has to be chrome 120.

1. download e.g. msedgedriver https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver for your system
1. unzip
1. run in bash/cmd
1. by default the driver server should run at http://localhost:9515

## TODO

### Docs

There are no docs and doc-comments yet - `roc docs` won't generate docs for a `package` that is importing a `platform`.

Waiting for `module params`.

### WebDriver Client

The [WebDriver.roc](package/WebDriver.roc) module is a thin http client wrapper for webdriver, and I try to stick to the [W3C Specification](https://www.w3.org/TR/webdriver2/).

It might be a good idea to extract this to a separate package if it grows.

Might be useful for web crawling, generating PDFs from html, and so on...
