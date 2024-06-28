# r2e

Roc2End is a toy End2End framework.

## Examples

### E2E testing

The `test` wrapper will make sure to cleanup after test and when they fail.

There is no way (yet) to run a list of tests - compiler bug.

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
    driver = Driver.create LocalServerWithDefaultPort

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

__WARNING: This package is importing modules from platform!__ - this will be blocked in future. Waiting for `module params` to refactor this.

For now - it just works...

To run examples in [examples]() you need a running webdriver (msedgedrive, chromedrive, geckodriver, etc.)

Make sure that the webdriver has the same version as your browser. e.g. when using chromedriver 120, your chrome also has to be chrome 120.

## TODO

### Docs

There are no docs and doc-comments yet - `roc docs` won't generate docs for a `package` that is importing a `platform`.

Waiting for `module params`.

### WebDriver Client

The [WebDriver.roc](package/WebDriver.roc) module is a thin http client wrapper for webdriver, and I try to stick to the [W3C Specification](https://www.w3.org/TR/webdriver2/).

It might be a good idea to extract this to a separate package if it grows.

Might be useful for web crawling, generating PDFs from html, and so on...
