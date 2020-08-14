# Native Alerts Integration

Native support in ThousandEyes for sending alerts to AppDynamics is currently on the product roadmap for Q1 2020 (Sept).

AppDynamics alerts can be triggered by external sources like ThousandEyes using the AppDynamics Alert and Respond API. This API allows generating alert events in AppD that can trigger alert policies and actions as well as overlay alerts in dashboards. The AppD documentation refers to this API as “Alert and Respond API”, as well as “Events and Action API”; we’ll refer to it as the AppD Alerts API to avoid confusion.

Users can setup alert notifications using the AppD notification drop-down in ThousandEyes. 

[image]

Once the notification is setup, the user can associate the notification with any Alert Rules they have setup in ThousandEyes. Once this is done, ThousandEyes will send full alert data to AppDynamics whenver the associated Alert. Here is an example of how alerts appear in AppD:

[image]

In addition, the `thousandeyes-alert-template.json`, shows example of setting up an alert policy for ThousandEyes alert in AppD.

