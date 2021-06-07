import jester, twitter
import parsecfg, json, htmlgen, uri, os, httpclient

routes:
  get "/":
    let page = form(action="/createString", `method`="POST", enctype="application/json",
                    input(`type`="text", name="username"),
                    input(`type`="text", name="message"),
                    input(`type`="submit", value="submit")
                )
    resp page

  post "/createString":
    let payload = request.params
    # Get Twitter ID from API
    let twitterName = payload["username"]
    var twitterID = ""

    let config = loadConfig(getHomeDir() & ".config/twitter_dm_intent/" & "twitter_bot.cfg")
    let consumerToken = newConsumerToken(config.getSectionValue("", "twitterConsumer"),
                                         config.getSectionValue("", "twitterConsumerSecret"))
    let twitterAPI = newTwitterApi(consumerToken,
                                   config.getSectionValue("", "twitterToken"),
                                   config.getSectionValue("", "twitterSecret"))

    let user = parseJson(twitterAPI.usersShow(twitterName).body)
    twitterID = $user["id"]

    # Create string
    let message = payload["message"]

    let query = {"text": $message, "recipient_id": $twitterID}
    let url = parseUri("https://twitter.com") / "messages" / "compose" ? query
    resp p($url)
