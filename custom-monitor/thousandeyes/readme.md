# ThousandEyes AppD Custom Monitor

This code is an example of a an AppD Machine Agent Custom Monitor for ThousandEyes that streams ThousandEyes metrics to AppD. This ThousandEyes Custom Monitor runs a Python script that periodically pulls test data from the ThousandEyes API and pushes data into AppD via:

* Analytics API or
* Custom Metrics 

While the Analytics API approach doesn’t require using an AppD Machine Agent, the Machine Agent Custom Monitor mechanism provides a convenient, simple, and reliable way to query the ThousandEyes API and push data to the Analytics API. For this reason, the example integration features using the Custom Monitor for both approaches.

## Setup and Usage

Copy the `thousandeyes` folder to `<appdinstall>/machine-agent/monitors/thousandeyes`. 

Update the configuration files with your connection and test info:

#### connection.json

* The `account-id` is your full Global Account Name located under License->Account (in the AppD controller UI).
* The `api-key` is your account Access Key under License->Account (or Rules if you have those setup).

```
{
	"analytics-api" : "https://analytics.api.appdynamics.com",
	"account-id" : "<your full appd account id>", 
	"api-key" : "<your appd api key>"
}
```

#### teappd-monitor.sh
Specify the ThousandEyes test and connection info to pull metrics from when calling Python script:

`teappd-monitor.py "<account group>" <email> <token> <test name> `

* account group - the ThousandEyes Account Group name
* email - your ThousandEyes login email
* token - you ThousandEyes API token
* test - the name of the test to pull data from

Multiple calls can be made to poll multiple tests:

```
./teappd-monitor.py "Integration AppD" "user@thousandeyes.com" "34jkoijdjo34" "MyTest"
./teappd-monitor.py "Integration AppD" "user@thousandeyes.com" "34jkoijdjo34" "MyOtherTest"
```

#### Install Python
For this example we're using a python script, so Python3 needs to be installed.

#### Make the ThousandEyes Monitor executable
`sudo chmod +x teappd-monitor.sh`
`sudo chmod +x teappd-monitor.py`

#### Enable Machine Agent as a Service (Optional)

```
sudo cp /opt/appdynamics/machine-agent/etc/systemd/system/appdynamics-machine-agent.service/etc/systemd/system/appdynamics-machine-agent.service
sudo systemctl enable appdynamics-machine-agent
sudo systemctl start appdynamics-machine-agent
sudo systemctl status appdynamics-machine-agent
```

* Check the Machine Agent logs *
`tail -n 100 /opt/appdynamics/machine-agent/logs/machine-agent.log`






