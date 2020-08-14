# ThousandEyes Machine Agent Extension 

This code provides an example of how to create an AppD Machine Agent Custom Monitor Extension for ThousandEyes. This Extension streams monitoring data from ThousandEyes to AppD. The Custom Monitor runs a Python script that periodically pulls test data from the ThousandEyes API, transforms the data payload, and pushes data into AppD via **Custom Metrics** and/or **Analytics Platform** (via analytics API).

## Prerequisites
Before the extension can be used the following prequistates must be in place:

* This extension collects data from the ThousandEyes REST API. Please make sure that the API is available and accessible. To access ThousandEyes REST API, you need a valid ThousandEyes user account with API permissions and an API Token. Please see https://developer.thousandeyes.com/ for more information on accessing the ThousandEyes API.

* This extension uses a Standalone Machine Agent. For more details on downloading these products, please visit https://docs.appdynamics.com/display/PRO45/Extensions+and+Custom+Metrics. The extension needs to be able to connect to ThousandEyes and AppD in order to collect and send metrics. 
 
**Note** - the ThousandEyes Monitor Machine Agent does NOT need to run in the same environemnt as your application.
**Note** - When using Custom Metrics, you must deploy a separate machine agent for each Application you want to monitor. Using Analytics you can monitor multiple applications with a single Machine Agent.

## Manual Setup and Usage

Copy the `thousandeyes` folder to `<appdinstall>/machine-agent/monitors/thousandeyes`. 

Update the configuration files with your connection and test info:

#### config.json

* `account-id` is your full Global Account Name located under License->Account. (Analytics Only)
* `api-key` is your account Access Key under License->Account (or Rules if you have those setup). (Analytics Only)
* `te-email` is your ThousandEyes Email
* `te-api-key` is your ThousandEyes API key
* `te-account group` - the ThousandEyes Account Group name
* `te-tests` - a list of tests to pull data from. Multiple tests supported.

```
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

** Note**: the AppDynamics `Application`, `Tier`, and `Node` must be specified as metadata in the `Description` section of any ThousandEyes tests that data is being pulled from. Metadata is json format, for example:

```json
{ 
    "appd_application":"<customerapp>", 
    "appd_tier":"<frontend>", 
    "appd_node":"<nodejs-1>"
}
```

** NOTE: ** 
When using ** Custom Metrics **, a single Machine Agent can only report metrics for a single Application in AppDynamics. See [https://docs.appdynamics.com/display/PRO40/Associate+Standalone+Machine+Agents+with+Applications](AppD Doc PRO40). To associate the MA with an Application 
* In the AppDynamics Agents window, select a Machine Agent. Click Associate with an Application. OR
* Deploy the machine agent on the same host as the app / Application Agent.

## Configuring a Machine Agent
#### configuration.env

Create .setup.sh and call that in Dockerfile.

#### Install Python
For this example we're using a python script, so Python3 needs to be installed.

#### Make the ThousandEyes Monitor executable
`sudo chmod +x teappd-monitor.sh`
`sudo chmod +x teappd-monitor.py`

#### Enable Machine Agent as a Service (Optional)

```
sudo cp /opt/appdynamics/machine-agent/etc/systemd/system/appdynamics-machine-agent.service /etc/systemd/system/appdynamics-machine-agent.service
sudo systemctl enable appdynamics-machine-agent
sudo systemctl start appdynamics-machine-agent
sudo systemctl status appdynamics-machine-agent
```

* Check the Machine Agent logs *
`tail -n 100 /opt/appdynamics/machine-agent/logs/machine-agent.log`


## Install On Docker Machine Agent
Example: adcapital docker host
ssh -i te-agent.pem ubuntu@44.229.47.134

Docker image is build from `openjdk:8-jre-slim`.
Machine Agent ZIP is copied in `Dockerfile`

Machine Agent is launched in container startup file
```

# Start Machine Agent
java ${MA_PROPERTIES} -jar ${MACHINE_AGENT_HOME}/machineagent.jar
```

try building container locally




#### Note on Metrics

* Metrics with the Custom Metrics prefix are common across all tiers in your application
* Metrics with the `Server|Component:<tier-name-or-tier-id>`` prefix appear only under the specified tier. If you attempt to publish metrics to a tier that is not associated with the Machine Agent, the metrics are not reported.


