# ThousandEyes Snapshot Integration

Create an AppDynamics HTTP Request Template that triggers a [Snapshot in ThousandEyes](https://docs.thousandeyes.com/product-documentation/tests/sharing-test-data). (Note that ThousandEyes Snapshots are different than AppDynamics snapshots). The HTTP Request Template will use the ThousandEyes API to create the snapshot.

This uses AppDynamics' HTTP Request Template webhook integration feature, similar to the ThousandEyes alert webhook notification. 

For each ThousandEyes test associated with a given AppDynamics application (or tier or node), we will create a separate HTTP request to trigger a ThousandEyes snapshot via the ThousandEyes API. 

We will create an HTTP request template so that the ThousandEyes snapshot time window and test ID can be provided dynamically.

## Create HTTP Request Template

1. Under **Alert & Respond**, select **HTTP Request Template**.
2. Click **+** (New)
3. Set up a HTTP request template to trigger a ThousandEyes snapshot:

### Name

Name the HTTP request **ThousandEyes Snapshot**.

### Set the Request URL

Set the request URL to **POST https://api.thousandeyes.com/v6/snapshot.json**.

[httprequest-url.png]

### Set Authentication

Set authentication to **Basic**. Use your ThousandEyes username and API token as password.

### Set the Payload

Note - Using Apache VTL to format time string in request.

In ThousandEyes, the test ID for the **adcapital** test is 1246117.

```
#set( $String = '' )
#set( $to = $String.format('%1$tY-%1$tm-%1$tdT%1$tH:%1$tM:%1$tS ', $latestEvent.eventTime))
#set( $tohour = $String.format('%1$tH', $latestEvent.eventTime))
#set($tohourint = 0)
#set( $fromhourint = $tohourint.parseInt($tohour) - 1)
#set( $fromhour = $fromhourint.toString())
#set( $from = $String.format('%1$tY-%1$tm-%1$tdT%2$s:%1$tM:%1$tS ', $latestEvent.eventTime, $fromhour))
{
    "testId": ${testid},
    "displayName": "Snapshot from AppDynamics - ${testname} - ${to}",
    "from": "${from}",
    "to": "${to}",
    "isPublic": 1
}
```

### Save the HTTP Request

[httprequest-save.png]


### Set up an Alert Policy to Trigger the HTTP Request

See [thousandeyes-snapshot-template.json](thousandeyes-snapshot-template.json) as an example of referencing the HTTP request template from an alert policy.

```
{
  "name": "ThousandEyes Snapshot Template",
  "description": null,
  "version": 1,
  "healthRuleMembers": [],
  "actionMembers": [
    {
      "model": {
        "id": 3884,
        "actionType": "HTTP_REQUEST",
        "name": "ThousndEyes Snapshot",
        "httpRequestTemplateName": "ThousandEyes Snapshot",
        "customTemplateVariables": [
          {
            "key": "Date",
            "value": "2/5/2020"
          },
          {
            "key": "Test",
            "value": "customerapp"
          }
        ]
      },
      "memberType": "ACTION"
    }
  ],
  "scheduleMembers": [],
  "actionSuppressionMembers": [],
  "emailDigestMembers": [],
  "policyMembers": []
}
```

[httprequest-action.png]
