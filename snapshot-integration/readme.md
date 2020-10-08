# ThousandEyes Snapshot Integration

Create an AppDynamics HTTP request template that triggers a [Snapshot in ThousandEyes](https://docs.thousandeyes.com/product-documentation/tests/sharing-test-data). (Note that ThousandEyes snapshots are different from AppDynamics snapshots.) The HTTP request template will use the ThousandEyes API to create the snapshot.

Once created, our HTTP request template can be called by actions defined in AppDynamics. We will define dynamic variables for the template - `testId`, `testName`, and `accountId` - that are specified by each action, so that a single HTTP request template can be used to trigger a snapshot for any test in ThousandEyes. 


## Create HTTP Request Template

1. Under **Alert & Respond**, select **HTTP Request Template**.
2. Click **+** (New)
3. Set up a HTTP request template to trigger a ThousandEyes snapshot:

### Set the Custom Templating Variables

Add the following custom templating variables:

* `accountId` - The ThousandEyes account that the snapshot will be created in. The default value can be set to a specific account ID, or specified by the calling action.
* `testId` - The ID of the test in ThousandEyes to trigger a snapshot on. No default value; this should be set by the calling action. Note - a test's ID can be found by viewing a test in ThousandEyes and looking for the `testId` parameter in the URL. For example: `https://app.thousandeyes.com/view/tests/?testId=1705574`
* `testName` - The name of the test in ThousandEyes. No default value; this should be set by the calling action.

Name the HTTP request **ThousandEyes Snapshot**.

### Set the Request URL

Set the request URL to **POST https://api.thousandeyes.com/v6/snapshot.json**.

[httprequest-url.png]

### Set Authentication

Set authentication to **Basic**. Use your ThousandEyes username and API token as password.

### Set the Payload

Note - Using Apache VTL to format time string in request.


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
