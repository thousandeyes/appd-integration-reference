# AppD Reference Integration

This project is a reference example of how to integrate ThosandEyes and AppDyanmics. It includes the following integration points:

* Sending ThousandEyes test data to AppDynamics - push ThousandEyes test data into AppDynamics via Machine Agent Custom Monitor and/or AppDynamics Analytics API. 

* ThousandEyes Alert Notification for AppDynamics - configure ThousandEyes alerts to trigger custom events in AppDynamics using AppDynamics Alert & Respond API. 

* Triggering ThousandEyes Snapshot from AppDynamics - configure AppDynamics to trigger a ThousandEyes snapshot based on a AppDynamics alert policy. 

* ThousandEyes Synthetic Test Injection - make AppDynamics aware of ThousandEyes network traffic that is targeting monitored applications. This allows AppD to perform more detailed tracing for traffic originating from ThousandEyes, allows filtering on ThousandEyes data, and correlating with AppD data. This must be configured manually when creating ThousandEyes tests.


## ThousandEyes AppD Integration Machine Agent

This ThousandEyes + AppDynamics reference integration illustrates how to leverage an AppDynamics Machine Agent to provide key integration capabilities. The example illustrates how to:

* Configure AppDynamics Machine Agent with a ThousandEyes Custom Monitor for streaming ThousandEyes metrics

* Transform ThousandEyes metrics to AppDynamics Analytics API using a Python script

* Transform ThousandEyes metrics to AppDynamics Custom Metrics using a Python script

* AppD and TE Dashboard and Test Examples

* Running a template based webhook server to transform Alerts to AppD (for on-prem deployments if native AppD notifications are not used) 

* Use a reverse proxy to facilitate connecting ThousandEyes to AppDynamics in an on-prem deployment

* Package the AppD Machine agent as a Docker Container with Terraform to support automated deployment of the Machine Agent to a customer's local / data center environment or to a public cloud environment.


