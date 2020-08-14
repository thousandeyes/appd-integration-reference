# AppDynamics Reference Integration

This project is a reference example of how to integrate ThosandEyes and AppDyanmics. It includes the following examples:

#### [`native-alerts`](native-alerts/readme.md)
ThousandEyes provides native alert integration with AppDynamics. This example shows how to setup ThousandEyes Alerts to create alert notifications in AppD. It also shows how to setup AppD policies to respond to ThousandEyes alerts

####  [`dashboards`](dashboards/readme.md)
Shows how to embed ThousandEyes dashboard widgets in AppD dashboards and includes a few dashboard examples.

#### [`custom-monitor`](custom-monitor/readme.md) 
ThousandEyes monitoring data can be pushed to AppDynamics with a ThousandEyes Custom Monitor (machine agent extension). This example shows how to create a custom monitor that pulls ThousandEyes test data from the ThousandEyes API and  pushes that data to AppDynamics via Custom Metrics and/or the AppDynamics Analytics API. The current example uses a Python script.

#### [`snapshot-integration`](snapshot-integration/readme.md) 
Shows how to trigger a ThousandEyes Snapshot from AppDynamics using AppD HTTP Request Template.

#### [`http-injection`](http-injection/readme.md)
Shows how to inject a unique ThousandEyes GUID to HTTP headers of ThousandEyes test. This makes AppDynamics aware of ThousandEyes network traffic that is targeting monitored applications. It allows AppD to perform more detailed tracing for traffic originating from ThousandEyes, allows filtering on ThousandEyes data, and easier correlation with AppD data.

