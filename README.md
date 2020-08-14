# AppD Reference Integration

This project is a reference example of how to integrate ThosandEyes and AppDyanmics. It includes the following examples:

#### [`alerts-integration`](alerts-integration/readme.md)

How to setup and handle ThousandEyes Alerts in AppD and how to setup AppD policies to respond to ThousandEyes alerts

####  [`dashboards`](dashboards/readme.md)
How to embed ThousandEyes dashboard widgets in AppD dashboards and includes a few dashboard examples.

#### [`custom-monitor`](custom-monitor/readme.md) 
How to create a ThousandEyes Monitor (machine agent extension) that pulls ThousandEyes test data from the ThousandEyes API and  pushes that data to AppDynamics via Custom Metrics and/or the AppDynamics Analytics API. 

#### [`snapshot-integration`](snapshot-integration/readme.md) 
How to trigger a ThousandEyes Snapshot from AppDynamics using AppD HTTP Request Template.

#### [`http-injection`](http-injection/readme.md)
How to inject a unique ThousandEyes GUID to HTTP headers of ThousandEyes test. This makes AppDynamics aware of ThousandEyes network traffic that is targeting monitored applications. It allows AppD to perform more detailed tracing for traffic originating from ThousandEyes, allows filtering on ThousandEyes data, and easier correlation with AppD data.

