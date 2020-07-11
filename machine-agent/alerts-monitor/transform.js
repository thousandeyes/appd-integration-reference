
const handlebarsalajson = require('handlebars-a-la-json');
const Handlebars = handlebarsalajson.createJsonHandlebars();
Handlebars.registerHelper('json', function(context) {
    return JSON.stringify(context);
});
Handlebars.registerHelper('ifCond', function(v1, v2, options) {
  if(v1 === v2) {
    return options.fn(this);
  }
  return options.inverse(this);
});

/**
 * Transforms an incomming ThousandEyes alert webhook notification to an outgoing API request. 
 * The `body` of the request is the ThousandEyes Alert JSON payload. 
 * See `https://docs.thousandeyes.com/product-documentation/alerts/using-webhooks-server-sample-code-included` for reference.
 *
 * Note - the incomming ThousandEyes webhook request must include a `url` parameter. 
 * This `url` parameter will be used as the URL for the outgoing API request.
 * 
 * For example, the ThousandEyes webhook request: `https://<your server>/appd?url=thousandeyesinc.saas.appdynamics.com`
 * would result in an outgoing API request to: `https:\\thousandeyesinc.saas.appdynamics.com` 
 *
 * Note - incomming webhook HTTP headers are forwarded to the outgoing API call in order to preserve any custom HTTP headers and authentication
 *
 * @param {JSON Object} event    The incomming ThousandEyes webhook notification request
 * @param {JSON Object} template The template object that describes how to convert ThousandEyes alert to target API call
 * @return {JSON Object}
 */
module.exports.transform = (event, template) => {
  // Transform the data payload (`body`), which is the ThousandEyes alert data 
  let transformed = (Handlebars.compile(JSON.stringify(template)))(JSON.parse(event['body']));
  transformed['baseUrl'] = "https://" + event['queryStringParameters']['url'];
  transformed['headers'] = event['headers'];
  return transformed;
}
