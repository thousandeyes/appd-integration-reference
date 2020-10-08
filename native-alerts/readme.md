# Native Alerts Integration

ThousandEyes natively supports sending alert notifications directly to AppDynamics. You can set up alert notifications using the AppDynamics notification drop-down in ThousandEyes. To learn more about the native alerts integration, see the official [ThousandEyes Documentation](https://docs.thousandeyes.com/product-documentation/alerts/appdynamics-integration). 

Once the notification is set up, you can associate the notification with any alert rules they have set up in ThousandEyes. Once this is done, ThousandEyes will send full alert data to AppDynamics whenever the associated alert is triggered. <!-- Here is an example of how alerts appear in AppDynamics: -->

In AppDynamics, ThousandEyes alerts show up as Custom Events of type `ThousandEyesAlert`.  The **thousandeyes-alert-template.json** file shows an example of an AppDynamics Alert Policy that is triggered by ThousandEyes alerts.
