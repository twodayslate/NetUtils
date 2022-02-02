const apiKeyKeyMap = new Map([
  ["webRisk", "key"],
  ["whoisXml", "apiKey"],
  ["whoisXmlReputation", "apiKey"],
  ["whoisXmlBalance", "apiKey"],
  ["monapi", "userKey"]
])

const apiKeyMap = new Map([
  ["webRisk", GOOGLE_WEB_RISK_API_KEY],
  ["whoisXml", WHOIS_XML_API_KEY],
  ["whoisXmlReputation", WHOIS_XML_API_KEY],
  ["whoisXmlBalance", WHOIS_XML_API_KEY],
  ["monapi", MONAPI_KEY]
]);

const apiHostMap = new Map([
  ["webRisk", "webrisk.googleapis.com"],
  ["whoisXml", "www.whoisxmlapi.com"],
  ["whoisXmlBalance", "user.whoisxmlapi.com"],
  ["whoisXmlReputation", "domain-reputation.whoisxmlapi.com"],
  ["monapi", "api.monapi.io"]
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



// async function handleRequest(request) {
//   let requestURL = new URL(request.url)
//   let path = requestURL.pathname.split('/redirect')[1]
//   let location = redirectMap.get(path)
//   if (location) {
//     return Response.redirect(location, 301)
//   }
//   // If in map, return the original request
//   return fetch(request)
// }
// addEventListener('fetch', async event => {
//   event.respondWith(handleRequest(event.request))
// })
// const externalHostname = 'workers-tooling.cf'
// const redirectMap = new Map([
//   ['/bulk1', 'https://' + externalHostname + '/redirect2'],
//   ['/bulk2', 'https://' + externalHostname + '/redirect3'],
//   ['/bulk3', 'https://' + externalHostname + '/redirect4'],
//   ['/bulk4', 'https://google.com'],
// ])


// async function handleRequest(request) {
//   /**
//    * Best practice is to only assign new properties on the request
//    * object (i.e. RequestInit props) through either a method or the constructor
//    */
//   let newRequestInit = {
//     // Change method
//     method: 'POST',
//     // Change body
//     body: JSON.stringify({ bar: 'foo' }),
//     // Change the redirect mode.
//     redirect: 'follow',
//     //Change headers, note this method will erase existing headers
//     headers: {
//       'Content-Type': 'application/json',
//     },
//     // Change a Cloudflare feature on the outbound response
//     cf: { apps: false },
//   }
//   // Change URL
//   let url = someUrl
//   // Change just the host
//   url = new URL(url)
//   url.hostname = someHost
//   // Best practice is to always use the original request to construct the new request
//   // thereby cloning all the attributes, applying the URL also requires a constructor
//   // since once a Request has been constructed, its URL is immutable.
//   const newRequest = new Request(url, new Request(request, newRequestInit))
//   // Set headers using method
//   newRequest.headers.set('X-Example', 'bar')
//   newRequest.headers.set('Content-Type', 'application/json')
//   try {
//     return await fetch(newRequest)
//   } catch (e) {
//     return new Response(JSON.stringify({ error: e.message }), { status: 500 })
//   }
// }
// addEventListener('fetch', event => {
//   event.respondWith(handleRequest(event.request))
// })
// /**
//  * Example someHost is set up to return raw JSON
//  * @param {string} someUrl the URL to send the request to, since we are setting hostname too only path is applied
//  * @param {string} someHost the host the request will resolve too
//  */
// const someHost = 'example.com'
// const someUrl = 'https://foo.example.com/api.js'
