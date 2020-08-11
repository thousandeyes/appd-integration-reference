# ThousandEyes AppD Custom Monitor

This code is an example of a an AppD Machine Agent Custom Monitor for ThousandEyes that streams ThousandEyes metrics to AppD. This ThousandEyes Custom Monitor runs a Python script that periodically pulls test data from the ThousandEyes API and pushes data into AppD via:

* Analytics API or
* Custom Metrics 

While the Analytics API approach doesn’t require using an AppD Machine Agent, the Machine Agent Custom Monitor mechanism provides a convenient, simple, and reliable way to query the ThousandEyes API and push data to the Analytics API. For this reason, the example integration features using the Custom Monitor for both approaches.

## Usage

Copy the `thousandeyes` folder to `<appdinstall>/machine-agent/monitors/thousandeyes`. 

Update the configuration files with your connection and test info:

#### connection.json

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





