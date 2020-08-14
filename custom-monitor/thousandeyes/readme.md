## Manual Setup and Usage

Copy the `thousandeyes` folder to `<appdinstall>/machine-agent/monitors/thousandeyes`. 

Update the configuration files with your connection and test info:

#### config.json

* The `account-id` is your full Global Account Name located under License->Account (in the AppD controller UI).
* The `api-key` is your account Access Key under License->Account (or Rules if you have those setup).
* 
* `te-account group` - the ThousandEyes Account Group name
* `te-tests` - a list of tests to pull data from. Multiple tests supported.

```json
{
    "analytics-api":"https://analytics.api.appdynamics.com",
    "account-id":"<AppDynamics Global Account ID>", 
    "api-key":"<AppDynamics API Key>",
    "te-email":"<ThousandEyes Email>",
    "te-api-key":"<ThousandEyes API Key>",
    "te-account-group":"<ThousandEyes Account Name>",
    "te-tests":["testA", "testB"]
}
```