// app.js

const express = require('express');
const app = express();
var https = require('https');
var http = require('http');
var axios = require('axios');

const makeRequest = require('./makerequest.js').makeRequest;
const transform = require('./transform.js').transform;

var fs = require('fs')
var path_module = require('path');

var httpsport = process.env.PORT || 8080;
var httpport = process.env.HTTPPORT || 8000;
var ngrokport = process.env.NGROKPORT || 4040;
var working = process.env.WORKING || ".";
var user_templates = process.env.USER_TEMPLATES || "user_templates"
var builtin_templates = process.env.TEMPLATES || "templates"
var templates={};

var privateKey  = "";
var certificate = "";
var sslcert = null;
try {
  privateKey  = fs.readFileSync('./sslcert/server.key').toString();
  certificate = fs.readFileSync('./sslcert/server.cert').toString(); 
  sslcert = {key: privateKey, cert: certificate};
}
catch (e) {
  console.log(e.message)
}



const start = new Date(Date.now()).toString();

const GREEN='\033[92m'
const BLUE='\033[96m'
const YELLOW='\033[93m'
const CLEAR='\033[0m'

var loadTemplates = function (folder) {
	fs.readdir(folder, function (err, files) {
    //handling error
    if (err) {
        return console.log('Unable to scan directory: ' + err);
    } 

    files.forEach(function (file) {
    	route = file.split('.')[0];
    	if (route in templates) {
    		return console.log("(Skipping " + file + "; template for " + route + " already exists.)");
      }
    	f = path_module.join(folder, file);
    	if (file.includes('.json')) {
    	  console.log("Loading " + f);
    		templates[route] = JSON.parse(fs.readFileSync(f));
	    } else if (file.includes('.js')) {
    	  console.log(`Loading ${folder}/${file}`);
    		templates[route] = require(`${folder}/${file}`).template;
			}
    });
	});
}

// Transforms needed for serverless formatted request
var validateRequest = function (req, res, next) {
  req.queryStringParameters = req.query; 									// "queryStringParameters" instead of "query"
  req.body = JSON.stringify(req.body);										// body needs to be stringified
  req.headers.Authorization = req.headers.authorization;	// Uppercase needed
  
  next()
}

async function queryNgrokTunnel (port) {
  try {
    let response = await axios.get(`http://127.0.0.1:${port}/api/tunnels`);
    return response.data.tunnels[0].public_url;
  } catch (e) {
    console.log(e.message)
  }
} 

// Process json payload
app.use(express.json()) 

// Validate JSON schema of incomming request
app.use(validateRequest)

app.get ('/*', async (req, res) => {
  var tunnel = await queryNgrokTunnel (ngrokport);
  var publicip = (await axios.get(`http://ifconf.me/`).then(function (response) {return response.data})).trim();
  var isCurl = !!req.headers['user-agent'].match(/curl/);
  var msg = isCurl ? `${BLUE}Shapeshifter Version:      ${GREEN}${process.env.npm_package_version}\n${BLUE}Shapeshifter Public URL:   ${GREEN}https://${publicip}:${httpsport}\n${BLUE}Shapeshifter Private URL:  ${GREEN}https://localhost:${httpsport}${CLEAR}\n${BLUE}Shapeshifter Tunneled URL: ${GREEN}${tunnel}${CLEAR}\n` : `
  <style>
    body {font-family: ubuntu, sans-serif;}
  </style>
  <H1>Shapeshifter</H1></br>
  <strong>Version:</strong>  ${process.env.npm_package_version}</br>
  <strong>Templates:</strong> ${Object.keys(templates)}</br>
  <strong>Server Started:</strong> ${start}</br>
  <strong>Local URL :</strong><a href=https://localhost:${httpsport}>https://localhost:${httpsport}</a></br>
  <strong>Public URL :</strong><a href=https://${publicip}:${httpsport}>https://${publicip}:${httpsport}</a></br>
  <strong>Tunneled URL:</strong> <a href=${tunnel}>${tunnel}</a></br>
  <strong>You're accessing from:</strong> ${req.ip}</br>
  ` 
  await res.send(msg);
})

app.post('/*', async (req, res) => {
	template = req.path.replace(/^\/|\/$/g, '');
	if (templates[template]) {
    await res.send (await makeRequest (transform (req, templates[template])));
	}
	else {
		console.log ("No template defined for " + template);
		await res.send({statusCode: 400, body: "No template defined for "  + template});
	}
})


loadTemplates(`./${builtin_templates}`);
loadTemplates(`./${user_templates}`);

https.createServer(sslcert, app).listen(httpsport, async (err) => {
  if (err) return console.log(`Something bad happened: ${err}`);
  await console.log(`Shapeshifter is listening on ${httpsport}`)
})


// http.createServer(app).listen(httpport, async (err) => {
//   if (err) return console.log(`Something bad happened: ${err}`);
//   await console.log(`Shapeshifter is listening on ${httpport}`)
// })