# ThousandEyes Snapshot Integration
Create a ThousandEyes snapshot when an AppDynamics Event / Alert occurs.

Define AppDynamics HTTP Request Template for each test associated with a given AppD application, tier, or node. AppDynamics HTTP Request Templates use Apache Velocity   to process custom variables.

Ideally, AppDynamics would be able to associate an application with one or more ThousandEyes tests (testIds) so as to avoid creating one snapshot per application

We’ll create a Snapshot request for the “adcapital” application.

### Set Request URL

`POST https://api.thousandeyes.com/v6/snapshot.json`
 

### Set Authentication

Basic - using ThousandEyes username and API token as password.


### Set Payload

Note - using Apache VTL to format time string in request.

In ThousandEyes, the “adcapital” test ID is 1246117.

```
#set($to = '') 
#set($from = '')
#set($calFrom = $latestEvent.eventTime.toCalendar($latestEvent.eventTime))
#set($calTo = $calFrom)
## 4 hour snapshot window
$calFrom.add(10, -4)
##$to.format('yyyy-MM-ddTHH:mm:ss',$calTo.time)
##$from.format('yyyy-MM-ddTHH:mm:ss',$calFrom.time)
$to.format('%1$tY-%1$tm-%1$tdT%1$tH:%1$tM:%1$tS ', $calTo.time)
$from.format('%1$tY-%1$tm-%1$tdT%1$tH:%1$tM:%1$tS ', $calFrom.time)
{
    "testId": 1246117,
    "displayName": "ADCapital - ${to}",
    "from": "${from}",
    "to": "${to}",
    "isPublic": 1
}
```

### Save HTTP Request


 

### Setup Alert Policy to Trigger HTTP Request


