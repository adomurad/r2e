app [main] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.11.0/SY4WWMhWQ9NvQgvIthcv15AUeA7rAIJHAHgiaSHGhdY.tar.br",
    json: "https://github.com/lukewilliamboswell/roc-json/releases/download/0.10.0/KbIfTNbxShRX1A1FgXei1SpO5Jn8sgP6HP6PXbi-xyA.tar.br",
    driver: "../src/main.roc",
}

import pf.Stdout
import pf.Task
import driver.Browser
import driver.Element
import driver.Driver

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

