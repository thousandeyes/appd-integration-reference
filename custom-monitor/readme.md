# ThousandEyes Machine Agent Extension 

This code provides an example of how to create an AppD Machine Agent Custom Monitor Extension for ThousandEyes. This Extension streams monitoring data from ThousandEyes to AppD. The Custom Monitor runs a Python script that periodically pulls test data from the ThousandEyes API, transforms the data payload, and pushes data into AppD via **Custom Metrics** and/or **Analytics Platform** (via analytics API).

![metrics image](.readme/metrics.png)

## Prerequisites
Before the extension can be used the following prequistates must be in place:

* This extension collects data from the ThousandEyes REST API. Please make sure that the API is available and accessible. To access ThousandEyes REST API, you need a valid ThousandEyes user account with API permissions and an API Token. Please see https://developer.thousandeyes.com/ for more information on accessing the ThousandEyes API.

* This extension uses a Standalone Machine Agent. For more details on downloading these products, please visit https://docs.appdynamics.com/display/PRO45/Extensions+and+Custom+Metrics. The extension needs to be able to connect to ThousandEyes and AppD in order to collect and send metrics. 
 
The ThousandEyes Monitor Machine Agent does not need to run in the same environemnt as your application. When using Custom Metrics, you can only associate a machine agient (the ThousandEyes Monitor) with one applicaiton. Therefore, if you want to associate metrics with an application you're monitoring, you must deploy one ThousandEyes Machine Agent extension for each applicaiton. Alternatively, using a "dummy app" allows monitoring multiple applications with one machine agent.  

Analytics can monitor multiple applications with a single Machine Agent.

## Setup and Usage

### Get the Code

If you're installing on an existing Machine Agent you can clone the GitHub repo or pull the zip archive using `wget`. Make sure `MACHINE_AGENT_HOME` is set.

```bash
apt-get update
apt-get install wget
wget https://github.com/thousandeyes/appd-integration-reference/archive/master.tar.gz && \
    tar -xzvf master.tar.gz && \
    sudo mkdir -p ${MACHINE_AGENT_HOME}/monitors && \
    sudo mv appd-integration-reference-master/custom-monitor/thousandeyes ${MACHINE_AGENT_HOME}/monitors && \
    rm -rf appd-integration-reference-master && rm master.tar.gz
```

### Install
Run `install.sh` in the `thousandeyes` folder to configure Python and some other dependencies.  
```bash
./${MACHINE_AGENT_HOME}/monitors/thousandeyes/install.sh
```

### Configure
You'll need to configure your connection info, metrics format, and what ThousandEyes tests you want to pull data from. You can edit the `config.json` file or use Environment Variables. Environment variables take precedence over the `config.json` file (making `config.json` optional).

#### config.json

```json
{
    "account-id":"", 
    "api-key":"",
    "te-email":"",
    "te-api-key":"",
    "te-accountgroup":"",
    "te-tests":[""],
    "metric-template":"",
    "schema-name":""
}
```

#### Environment Variables

```bash
APPD_GLOBAL_ACCOUNT
APPD_API_KEY
TE_EMAIL
TE_API_KEY
TE_ACCOUNTGROUP
TE_TESTS 
TE_METRIC_TEMPLATE
TE_SCHEMA_NAME
```

* `APPD_GLOBAL_ACCOUNT`/`account-id` is your full Global Account Name located under License->Account. (Analytics Only)
* `APPD_API_KEY`/`api-key` is your account Access Key under License->Account (or Rules if you have those setup). (Analytics Only)
* `TE_EMAIL`/`te-email` is your ThousandEyes Email
* `TE_API_KEY`/`te-api-key` is your ThousandEyes API key
* `TE_ACCOUNTGROUP`/`te-account group` is the ThousandEyes Account Group name
* `TE_TESTS`/`te-tests` is an array of tests to pull data from. Multiple tests supported. Note, this is a json array eg `["test1","test2"]`; When set as an environment variable you must include outer single quotes: `'["test1","test2"]'`. 

```bash
TE_TESTS='["mytest1", "mytest2"]'
```

When passing as an environment variable to `docker-compose`, you must omit the outer ' ' (due to yaml parsing). This can feel odd as it's not valid bash.

```bash
TE_TESTS=["mytest1", "mytest2"]
```

* `TE_METRIC_TEMPLATE`/`metric-template` is the format of the Custom Metric. Some examples:
    - `name=Server|Component:{tier}|{agent}|{metricname},value={metricvalue}`
    - `name=Custom Metrics|{tier}|{agent}|{metricname},value={metricvalue}`
    - `name=Custom Metrics|{app}|{tier}|{agent}|{metricname},value={metricvalue}`

The metric template supports the variables `{app}`, `{tier}`, `{node}`. These variables are set by metadata you can place in the `Description` field of the ThousandEyes tests. The metadata format is: 

```json
{ 
    "appd_application":"myapp", 
    "appd_tier":"myapptier", 
    "appd_node":"mynode"
}
```

Where `appd_application` sets `{app}`, `appd_tier` sets `{tier}`, and `appd_node` sets `{node}`. The **metric template** also supports `{metricname}` and `{metricvalue}` which are set the the name and value of each metric.


* `TE_SCHEMA_NAME`/`schema-name` is the name of the schema that will be used for Analytics. This is optional and defaults to `thousandeyes`. If you change the `schema.json` file you must change the name of the schema to a new and unique schema name.

#### metrics.json
The **metrics.json** defines the list of ThousandEyes metrics to monitor and their name is they will appear in AppDynamics. This file does not need to be changed unless you want to add or remove ThousandEyes Metrics. The default metrics are:

```json
{ 
    "pageLoadTime": "Page Load",
    "domLoadTime": "DOM Load",
    "dnsTime": "DNS Time",
    "responseTime": "Response Time",
    "connectTime": "Connect Time",
    "waitTime": "Wait Time",
    "receiveTime": "Receive Time",
    "totalTime": "Total Time",
    "totalSize": "Total Size", 
    "responseCode": "Response Code",
    "numRedirects": "Redirectes",
    "wireSize": "Wire Size",
    "avgLatency": "Avg Latency",
    "maxLatency": "Max Latency",
    "minLatency": "Min Latency",
    "loss": "Loss",
    "jitter": "Jitter"
} 
```

**NOTE** - the ThousandEyes monitor currently supports pulling metrics from the following types of ThousandEyes tests:

* Page Load
* HTTP/Web
* Network

The various metrics values that are available can be found [here](https://developer.thousandeyes.com/v6/tests/#/test_metadata). 

The `monitor.py` file can be enhanced to pull additional metrics from ThousandEyes using additional API endpoints. For example - Path Trace metrics can be pulled from the `/net/path-viz` endpoint. Additional information can be found at 
[developer.thousandeyes.com](https://developer.thousandeyes.com/).

### Associating your Machine Agent with an Application
To associate the ThousandEyes Monitor machine agent with an Application in AppDynamics you need to set the following environment variables:

```bash
APPDYNAMICS_AGENT_APPLICATION_NAME=yourapp
APPDYNAMICS_AGENT_TIER_NAME=thousandeyes
APPDYNAMICS_AGENT_NODE_NAME=thousandeyes
```

Set `APPDYNAMICS_AGENT_APPLICATION_NAME` to the Application name of an application in AppDynamics. 

Set `APPDYNAMICS_AGENT_TIER_NAME` and `APPDYNAMICS_AGENT_NODE_NAME` to `thousandeyes`. This is the default recommended, but can be changed if desired. The ThousandEyes Monitor will appear under the specified application as a `thousandeyes` Java tier.

Note that Custom Metrics only allow associating a Machine Agent with a **single application** in AppDynamics. When writing metrics to an app you're monitoring in Appd you'll most likely want to use one of the following metric templates:

* `name=Server|Component:{tier}|{agent}|{metricname},value={metricvalue}`
* `name=Custom Metrics|{tier}|{agent}|{metricname},value={metricvalue}`

These will appear under the Application's Metrics under each Tier that we're generating metrics for.

In some cases you may want to use a single machine agent monitor to stream data for *multiple applicaitons*. In this scenario, you can consider creating a "dummy Application" in Appdynamics and associating the machine agent with that App. This will not be the same app as the apps you're monitor. Using a dummy application will allow collecting metrics for multiple applications using a single ThousandEyes Monitor machine agent. In this case you will most likely want to use the following metric template:

* `name=Custom Metrics|{app}|{tier}|{agent}|{metricname},value={metricvalue} `

Note the addition of the `{app}` variable, allowing multiple applications (as specified in the ThousandEyes test metadata) to report data under the same machine agent / dummy app.  


### Monitor Config XML 
The **monitor.xml** does not need to be modified. The only reason to modify it would be to change the execution to `continuous` mode. This requires updating the Python code to run continuously and should use the `metric-period`/`TE_METRIC_PERIOD` configuration value.

### Additional Machine Agent Settings
The following machine agent environment settings may also need to be configured. However, if running on an existing Machine Agent these should already be set:

* APPDYNAMICS_AGENT_ACCOUNT_NAME
* APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY
* APPDYNAMICS_CONTROLLER_HOST_NAME
* APPDYNAMICS_CONTROLLER_PORT
* APPDYNAMICS_CONTROLLER_SSL_ENABLED

**NOTE** - see [/appd-integration-reference/custom-monitor-docker] for deploying the ThousandEyes Monitor machine agent as a pre-built Docker Container.

### Check if ThousandEyes Monitor is running

```
tail -n 50 /opt/appdynamics/machine-agent/logs/machine-agent.log
```

You should see logs of the monitor being run periodically:
```
[Agent-Monitor-Scheduler-4] 20 Aug 2020 05:01:35,386  INFO PeriodicTaskRunner - Periodic Task - setup metric feed for [ThousandEyesMonitor]
[Agent-Monitor-Scheduler-4] 20 Aug 2020 05:01:35,386  INFO PeriodicTaskRunner - Returning time out value of [120000] ms for monitor task [ThousandEyesMonitor]
[Agent-Monitor-Scheduler-4] 20 Aug 2020 05:01:35,387  INFO ExecTask - Running Executable Command [[/opt/appdynamics/machine-agent/monitors/thousandeyes/monitor.sh]]
[Agent-Monitor-Scheduler-4] 20 Aug 2020 05:01:41,639  INFO MonitorStreamConsumer - Stopping monitored process
```

### docker-compose and quoted environment variables

When the following bash conforming environment variable file

```bash
TE_ACCOUNTGROUP="Integration AppD"
TE_TESTS='["samplenodejs2"]'
TE_SCHEMA_NAME=thousandeyes
```

is passed as an environment to `docker-compose`, it is parsed by `yaml` which, unlike `bash`, aims preserve all quotes, including outer quotes. The resulting environment variables (in the Docker container) are thus rendered with unexpected extra quotes:

```bash
TE_ACCOUNTGROUP='"Integration AppD"'
TE_TESTS='["samplenodejs2"]'
TE_SCHEMA_NAME=thousandeyes
```

