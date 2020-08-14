
# HTTP GUID Injection
ThousandEyes can include a unique GUID as a custom header (`PartnerGUID`) in the HTTP headers of the ThousandEyes test traffic that target applications AppD is monitoring. Doing so will make AppD agents aware of incomming ThousandEyes traffic. This allows AppD to perform more detailed tracing for traffic originating from ThousandEyes, allows filtering on ThousandEyes data, and makes it easier correlate ThousandEyes data with AppD data.

### Setting up Custom HTTP Collector in AppDynamics
An HTTP data collector named ‘PartnerGUID’ should be configured on the AppDynamics application so that the additional HTTP header (PartnerGUID) can becaptured and then persisted in the snapshots.

[httpcollector.png]

### Setting up ThousandEyes Tests
ThousandEyes tests that are targeting AppD monitored applications must be configured with the following custom HTTP headers:

```
PartnerGUID: exk4nqvxi3dr6qWAl2p7
appdynamicssnapshotenabled: true
```

Note that you may want to disable `appdynamicssnapshotenabled` for tests that are running at high frequency (e.g. 1 or 2 min) and create a duplicate test with `appdynamicssnapshotenabled` that runs at a lower interval (e.g. 10 min). 

[httpheader.png]


