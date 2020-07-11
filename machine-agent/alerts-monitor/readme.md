# AppD Alert Webhook Transformation
 
Transforms an incomming ThousandEyes alert webhook notification to an outgoing API request. 
The `body` of the request is the ThousandEyes Alert JSON payload. 
 
See `https://docs.thousandeyes.com/product-documentation/alerts/using-webhooks-server-sample-code-included` for reference.

Note - the incomming ThousandEyes webhook request must include a `url` parameter. 
This `url` parameter will be used as the URL for the outgoing API request.
  
For example, the ThousandEyes webhook request: `https://<your server>/appd?url=thousandeyesinc.saas.appdynamics.com` would result in an outgoing API request to: `https:\\thousandeyesinc.saas.appdynamics.com`  

Note - incomming webhook HTTP headers are forwarded to the outgoing API call in order to preserve any custom HTTP headers and authentication