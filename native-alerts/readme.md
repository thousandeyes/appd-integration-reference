# Native Alerts Integration

AppDynamics alerts can be triggered by external sources like ThousandEyes using the AppDynamics Alert & Respond API. This API allows generating alert events in AppDynamics that can trigger alert policies and actions as well as overlay alerts in dashboards. The AppDynamics documentation refers to this API as “Alert and Respond API,” as well as “Events and Action API”; we’ll refer to it as the AppDynamics Alerts API to avoid confusion.

You can set up alert notifications using the AppDynamics notification drop-down in ThousandEyes. 

Once the notification is set up, you can associate the notification with any alert rules they have set up in ThousandEyes. Once this is done, ThousandEyes will send full alert data to AppDynamics whenever the associated alert is triggered. <!-- Here is an example of how alerts appear in AppDynamics: -->

In addition, **thousandeyes-alert-template.json** shows an example of setting up an alert policy for a ThousandEyes alert in AppDynamics.

