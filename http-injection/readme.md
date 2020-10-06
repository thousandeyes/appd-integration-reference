
# HTTP GUID Injection

ThousandEyes can include a unique GUID as a custom header (`PartnerGUID`) in the HTTP headers of the ThousandEyes test traffic that target applications AppDynamics is monitoring. Doing so will make AppDynamics agents aware of incomming ThousandEyes traffic. This allows AppDynamics to perform more detailed tracing for traffic originating from ThousandEyes, allows filtering on ThousandEyes data, and makes it easier correlate ThousandEyes data with AppDynamics data.

### Setting up a Custom HTTP Collector in AppDynamics

An HTTP data collector named **PartnerGUID** should be configured on the AppDynamics application so that the additional HTTP header (PartnerGUID) can be captured and can persist in the snapshots.

[httpcollector.png]

### Setting up ThousandEyes Tests

ThousandEyes tests that are targeting AppDynamics-monitored applications must be configured with the following custom HTTP headers:

```
PartnerGUID: exk4nqvxi3dr6qWAl2p7
appdynamicssnapshotenabled: true
```

Note that you may want to disable `appdynamicssnapshotenabled` for tests that are running at high frequency (such as one- or two-minute intervals) and create a duplicate test with `appdynamicssnapshotenabled` that runs at a lower interval (such as 10 minutes). 

[httpheader.png]

