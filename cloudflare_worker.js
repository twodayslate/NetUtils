const apiKeyKeyMap = new Map([
  ["webRisk", "key"],
  ["whoisXml", "apiKey"],
  ["whoisXmlReputation", "apiKey"],
  ["whoisXmlBalance", "apiKey"],
  ["monapi", "userKey"],
  ["ipifyGeo", "apiKey"],
  ["ipifyVpnProxy", "apiKey"],
  ["shodan", "key"],
  ["whoisXmlDomainAvailability", "apiKey"],
  ["whoisXmlIpGeo", "apiKey"],
  ["whoisXmlWebsiteCategorization", "apiKey"],
  ["whoisXmlWebsiteContact", "apiKey"],
  ["whoisXmlEmailVerification", "apiKey"]
])

const apiKeyMap = new Map([
  ["webRisk", GOOGLE_WEB_RISK_API_KEY],
  ["whoisXml", WHOIS_XML_API_KEY],
  ["whoisXmlReputation", WHOIS_XML_API_KEY],
  ["whoisXmlBalance", WHOIS_XML_API_KEY],
  ["monapi", MONAPI_KEY],
  ["ipifyGeo", IPIFY_KEY],
  ["ipifyVpnProxy", IPIFY_KEY],
  ["shodan", SHODAN_API_KEY],
  ["whoisXmlDomainAvailability", WHOIS_XML_API_KEY],
  ["whoisXmlIpGeo", WHOIS_XML_API_KEY],
  ["whoisXmlWebsiteCategorization", WHOIS_XML_API_KEY],
  ["whoisXmlWebsiteContact", WHOIS_XML_API_KEY],
  ["whoisXmlEmailVerification", WHOIS_XML_API_KEY]
]);

const apiHostMap = new Map([
  ["webRisk", "webrisk.googleapis.com"],
  ["whoisXml", "www.whoisxmlapi.com"],
  ["whoisXmlBalance", "user.whoisxmlapi.com"],
  ["whoisXmlReputation", "domain-reputation.whoisxmlapi.com"],
  ["monapi", "api.monapi.io"],
  ["ipify", "api64.ipify.org"],
  ["ipifyGeo", "geo.ipify.org"],
  ["ipifyVpnProxy", "vpn-proxy-detection.ipify.org"],
  ["shodan", "api.shodan.io"],
  ["whoisXmlDomainAvailability", "domain-availability.whoisxmlapi.com"],
  ["whoisXmlIpGeo", "ip-geolocation.whoisxmlapi.com"],
  ["whoisXmlWebsiteCategorization", "website-categorization.whoisxmlapi.com"],
  ["whoisXmlWebsiteContact", "website-contacts.whoisxmlapi.com"],
  ["whoisXmlEmailVerification", "emailverification.whoisxmlapi.com"]
]);

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

/**
 * Respond to the request
 * @param {Request} request
 */
async function handleRequest(request) {
  let requestURL = new URL(request.url);
  let params = new URLSearchParams(requestURL.search);
  let api = params.get("api");
  let newRequest = new Request(request);
  params.delete("api")
  params.delete("service_name")
  params.delete("service_id")
  params.delete("identifierForVendor") // to be saved for later
  params.delete("bundleIdentifier") // to be saved for later
  requestURL.search = params;
  if (api) {
    let host = apiHostMap.get(api);
    if (host) {
      let key = apiKeyMap.get(api);
      let keyKey = apiKeyKeyMap.get(api);
      if (params.get(keyKey) == undefined) {
        //console.log("setting key", key)
        params.append(keyKey, key);
        newRequest.headers.set("Authorization", "Token " + key)
      } else {
        //console.log("User token provided", params.get(keyKey))
        newRequest.headers.set("Authorization", "Token " + params.get(keyKey))
      }
      requestURL.search = params;
      requestURL.hostname = host;
      try {
        return await fetch(requestURL, newRequest)
      } catch (e) {
        return new Response(JSON.stringify({ error: e.message }), { status: 500 })
      }
    }
  }
  
  return new Response("{ \"error\": \"No API specified\" }", {status: 500});
}
