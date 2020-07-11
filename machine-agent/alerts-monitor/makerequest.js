// Axios - a promise based http library from Facebook 
// https://github.com/axios/axios 
const axios = require('axios').default;

module.exports.makeRequest = async options => {
  let statusCode = 400;
  let message = "Unknown Error";
  try {
    await axios ({
      baseURL:  options['baseUrl'],
      url:      options['path'],
      method:   options['method'],
      params:   options['parameters'],
      data:     options['data'],
      timeout:  10000,
      headers:  options['auth'] ? {Authorization: options['headers']['Authorization']} : {},
    }) 
    .then(function (response) {
      statusCode = response.status;
      message = response.data;
    })
    .catch(error => {
      statusCode = 400;
      message = `${error}`;
    });
  } catch (error) {
      statusCode = 400;
      message = `${error.message}`; 
  }

  // Return response in {statusCode: , body: } format:
  let response = { 
    statusCode: statusCode, 
    body: JSON.stringify( {
        message: message,
      },
      null,
      2
    )
  };
  return response;
}