# ThousandEyes Machine Agent Extension 

This code provides an example of how to create an AppD Machine Agent Custom Monitor Extension for ThousandEyes. This Extension streams monitoring data from ThousandEyes to AppD. The Custom Monitor runs a Python script that periodically pulls test data from the ThousandEyes API, transforms the data payload, and pushes data into AppD via **Custom Metrics** and/or **Analytics Platform** (via analytics API).

## Prerequisites
Before the extension can be used the following prequistates must be in place:

* This extension collects data from the ThousandEyes REST API. Please make sure that the API is available and accessible. To access ThousandEyes REST API, you need a valid ThousandEyes user account with API permissions and an API Token. Please see https://developer.thousandeyes.com/ for more information on accessing the ThousandEyes API.

* This extension uses a Standalone Machine Agent. For more details on downloading these products, please visit https://docs.appdynamics.com/display/PRO45/Extensions+and+Custom+Metrics. The extension needs to be able to connect to ThousandEyes and AppD in order to collect and send metrics. ** Note ** - the Machine Agent does NOT need to run in the same environemnt as your application.


## Setup and Usage

Copy the `thousandeyes` folder to `<appdinstall>/machine-agent/monitors/thousandeyes`. 

Update the configuration files with your connection and test info:

#### connection.json

* The `account-id` is your full Global Account Name located under License->Account (in the AppD controller UI).
* The `api-key` is your account Access Key under License->Account (or Rules if you have those setup).

```
{
    "analytics-api":"https://analytics.api.appdynamics.com",
    "account-id":"<AppDynamics Global Account ID>", 
    "api-key":"<AppDynamics API Key>",
    "te-email":"<ThousandEyes Email>",
    "te-api-key":"<ThousandEyes API Key>"
}
```

#### teappd-monitor.sh
Specify the ThousandEyes test and connection info to pull metrics from when calling Python script:

`teappd-monitor.py "<account group>" <test name> `

* account group - the ThousandEyes Account Group name
* test - the name of the test to pull data from

Multiple tests can be specified and multiple calls can be made to poll multiple account groups:

```
./teappd-monitor.py "MyAccountGroup" "MyTestA" "MyTestB"
./teappd-monitor.py "MyOtherAccountGroup" "MyTestC"
```

**NOTE** The AppDynamics `Application`, `Tier`, and `Node` MUST be specified as metadata in the `Description` section of your ThousandEyes test. Metadata is json format:

```json
{ 
    "appd_application":"<appd application name>", 
    "appd_tier":"<appd application tier>", 
    "appd_node":"<appd tier node>"
}
```

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





