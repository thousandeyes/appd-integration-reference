# AppDynamics Reference Integration

This project is a reference example of how to integrate ThousandEyes and AppDynamics. It includes the following examples:

####  [`dashboards`](dashboards/readme.md)
This section shows how to embed ThousandEyes dashboard widgets in AppDynamics dashboards, and includes a few dashboard examples.

#### [`native-alerts`](native-alerts/readme.md)
ThousandEyes provides native alert integration with AppDynamics. See the ThousandEyes [AppDynamics alert integration docs](https://docs.thousandeyes.com/product-documentation/alerts/integrations/appdynamics-integration) for more details. This example shows how to set up ThousandEyes alerts, and how to set up AppDynamics policies to respond to ThousandEyes alerts.

#### [`snapshot-integration`](snapshot-integration/readme.md) 
This section shows how to trigger a ThousandEyes snapshot from AppDynamics using an AppDynamics HTTP request template.

#### [`custom-monitor`](custom-monitor/readme.md) 
ThousandEyes monitoring data can be pushed to AppDynamics with a ThousandEyes custom monitor (machine agent extension). This example shows how to create a custom monitor that pulls ThousandEyes test data from the ThousandEyes API and pushes that data to AppDynamics via custom metrics and/or the AppDynamics Analytics API. The current example uses a Python script.

#### [`http-injection`](http-injection/readme.md)
This section shows how to inject a unique ThousandEyes GUID into the HTTP headers of a ThousandEyes test. This makes AppDynamics aware of ThousandEyes network traffic that is targeting monitored applications. It allows more detailed tracing for traffic originating from ThousandEyes, filtering on ThousandEyes data, and easier correlation with AppDynamics data.

