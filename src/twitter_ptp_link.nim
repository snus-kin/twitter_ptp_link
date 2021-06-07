import jester, twitter
import parsecfg, json, uri, os, httpclient

routes:
  get "/":
    const page = staticRead"index.html"
    resp page

  get "/style.css":
    const style = staticRead"style.css"
    resp style

  post "/createString":
    let payload = parseJson(request.body)
    # Get Twitter ID from API
    let twitterName = $payload["twname"]
    var twitterID = ""

    let config = loadConfig(getHomeDir() / ".config/twitter_ptp_link" / "keys.cfg")
    let consumerToken = newConsumerToken(config.getSectionValue("", "twitterConsumer"),
                                         config.getSectionValue("", "twitterConsumerSecret"))
    let twitterAPI = newTwitterApi(consumerToken,
                                   config.getSectionValue("", "twitterToken"),
                                   config.getSectionValue("", "twitterSecret"))

    let user = parseJson(twitterAPI.usersShow(twitterName[1..twitterName.high-1]).body)

    try:
      twitterID = $user["id"]
    except:
      # If there's no ID we can 502
      resp Http502

    # Create string
    let message = $payload["message"]
    let strippedMessage = message[1..message.high-1]

    let query = {"text": $strippedMessage, "recipient_id": $twitterID}
    let url = parseUri("https://twitter.com") / "messages" / "compose" ? query
    resp $url
