# AppD Machine Agent ThoousandEyes Custom Monitor

`te-custom-monitor` is an example of a an AppD Machine Agent Custom Monitor for ThousandEyes that streams ThousandEyes metrics to AppD. This ThousandEyes Custom Monitor runs a Python script that periodically pulls test data from the ThousandEyes API and pushes data into AppD via:

* Analytics API or
* Custom Metrics 

Note that while the Analytics API approach doesn’t require using an AppD Machine Agent, the Machine Agent Custom Monitor mechanism provides a convenient, simple, and reliable way to query the ThousandEyes API and push data to the Analytics API. For this reason, the example integration features using the Custom Monitor for both approaches.

### Custom Event (Alert) JSON Payload:

```
POST /api/v1/events
[
  {
    "eventSeverity": <event_severity>,
    "type": "<event_type>",
    "summaryMessage": "<event_summary>",
    "properties": {
      "<key>": {
        <user-specified_object>
      },...
    },
    "details": {
      "<key>": "<value>"
    }
  }
]
```
