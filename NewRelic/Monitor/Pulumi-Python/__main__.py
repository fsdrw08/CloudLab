import pulumi
import pulumi_newrelic
from typing import List

from Modules.alert_bundle import NewrelicAlertBundle

config = pulumi.Config()


script_monitor_config = config.require_object("scriptMonitor")
script_monitor = pulumi_newrelic.synthetics.ScriptMonitor(
    script_monitor_config["name"],
    type="SCRIPT_API",
    runtime_type="NODE_API",
    runtime_type_version="16.10",
    script=nrScript.getFullNRScript(),
    **script_monitor_config,
    tags=tags,
)

one_dashboard_config = config.require_object("oneDashboard")
dashboard = pulumi_newrelic.OneDashboard(
    one_dashboard_config["name"],
    name=one_dashboard_config["name"],
    permissions=one_dashboard_config.get("permissions", None),
    pages=[
        pulumi_newrelic.OneDashboardPageArgs(
            name=page["name"],
            widget_tables=[
                pulumi_newrelic.OneDashboardPageWidgetTableArgs(
                    title=widget_table["title"],
                    nrql_queries=[
                        pulumi_newrelic.OneDashboardPageWidgetTableNrqlQueryArgs(
                            query=pulumi.Output.all(guid=script_monitor.guid).apply(
                                lambda args: query["query"].format(args["guid"])
                            ),
                        )
                        for query in widget_table["nrql_queries"]
                    ],
                    column=widget_table["column"],
                    row=widget_table["row"],
                    width=widget_table["width"],
                    height=widget_table["height"],
                    ignore_time_range=False,
                )
                for widget_table in page["widget_tables"]
            ],
        )
        for page in one_dashboard_config["pages"]
    ],
)


# We need to get script_monitor's guid, render the guid into alert_condition's query under the list object nrql_alert_conditions_config
# which get from pulumi config "nrqlAlertConditions",
# then pass the updated(rendered) object as a argument into the custom resource component (aka terraform's module).
#
# new relic script_monitor's guid is a "output" of pulumi,
# regarding to https://www.pulumi.com/docs/concepts/inputs-outputs/apply/#creating-new-output-values
# "output" are asynchronous, it's an unknown value, in pulumi, we can only express this output value by the "apply" method.
# the "apply" method will return a output object, it's a async function object, not a static value
#
# We have to figure out: how to pass the pulumi output object into the place you want
# in this case, we need to pass the pulumi output object into a list of object
# compare to the previous solution https://github.com/pulumi/pulumi-newrelic/issues/817
# should better put the pulumi output apply process inside a function, to reduce the side effect
def update_nrql_alert_condition_config(nrqlAlertCondition: List, script_monitor: pulumi_newrelic.synthetics.ScriptMonitor):
    query: str = nrqlAlertCondition["nrql"]["query"]
    # in order to put script monitor guid into the query, we have to use below method to present the query string
    # this makes nrqlAlertCondition["required"]["nrql"]["query"] as a pulumi output object
    nrqlAlertCondition["nrql"]["query"] = script_monitor.guid.apply(lambda guid: query.format(guid))
    return nrqlAlertCondition


nrql_alert_conditions_config = config.require_object("nrqlAlertConditions")
notification_channels_config = config.get_object("notificationChannels")
workflows_config = config.get_object("workflows")


NewrelicAlertBundle(
    project_name=script_monitor_config["name"],
    alert_policy_args=config.require_object("alertPolicy"),
    nrql_alert_conditions_args=map(
        lambda nrqlAlertCondition: update_nrql_alert_condition_config(nrqlAlertCondition, script_monitor),
        nrql_alert_conditions_config,
    ),
    notification_channels_args=notification_channels_config,
    workflows_args=workflows_config,
    opts=pulumi.ResourceOptions(depends_on=script_monitor),
)
