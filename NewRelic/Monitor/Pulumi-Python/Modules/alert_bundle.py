from typing import Dict, List, Optional
import pulumi
import pulumi_newrelic


# https://github.com/pawelros/leviathan/blob/f28e361d2d71128462ae90bfe3982d3884605538/leviathan/vpc.py#L64
class NewrelicAlertBundle(pulumi.ComponentResource):
    def __init__(
        self,
        project_name: str,
        alert_policy_args: Dict,
        nrql_alert_conditions_args: List,
        notification_channels_args: List,
        workflows_args: List,
        opts=None,
    ):
        super().__init__("custom:resource:NewRelicAlerts", project_name, {}, opts)

        # Create the Alert Policy
        self.alert_policy = pulumi_newrelic.AlertPolicy(
            f"Alert_Bundle-alert_policy", **alert_policy_args, opts=pulumi.ResourceOptions(parent=self)
        )

        # NRQL Alert Conditions
        self.nrql_alert_conditions = []

        for nrql_alert_condition_args in nrql_alert_conditions_args:
            nrql_alert_condition = pulumi_newrelic.NrqlAlertCondition(
                nrql_alert_condition_args["name"],
                # required args
                policy_id=self.alert_policy.id,
                name=nrql_alert_condition_args["name"],
                nrql=pulumi_newrelic.NrqlAlertConditionNrqlArgs(query=nrql_alert_condition_args["nrql"]["query"]),
                critical=(
                    None
                    if nrql_alert_condition_args.get("critical", None) is None
                    else pulumi_newrelic.NrqlAlertConditionCriticalArgs(**nrql_alert_condition_args["critical"])
                ),
                warning=(
                    None
                    if nrql_alert_condition_args.get("warning", None) is None
                    else pulumi_newrelic.NrqlAlertConditionWarningArgs(**nrql_alert_condition_args["warning"])
                ),
                # optional args
                **nrql_alert_condition_args["optional"],
                opts=pulumi.ResourceOptions(parent=self),
            )
            self.nrql_alert_conditions.append(nrql_alert_condition)

        # notification channels
        self.notification_channels_dict = {}
        for notification_channel_args in notification_channels_args:
            notification_channel = pulumi_newrelic.NotificationChannel(
                notification_channel_args["name"],
                name=notification_channel_args["name"],
                type=notification_channel_args["type"],
                product=notification_channel_args["product"],
                destination_id=notification_channel_args["destination_id"],
                properties=[
                    pulumi_newrelic.NotificationChannelPropertyArgs(**property)
                    for property in notification_channel_args.get("properties", [])
                ],
                opts=pulumi.ResourceOptions(parent=self),
            )
            self.notification_channels_dict[notification_channel_args["name"]] = notification_channel

        # Workflows
        for workflow_args in workflows_args:
            workflow_args["issues_filter"]["predicates"].insert(
                0,
                {
                    "attribute": "labels.policyIds",
                    "operator": "EXACTLY_MATCHES",
                    "values": [self.alert_policy.id],
                },
            )
            self.workflows = pulumi_newrelic.Workflow(
                workflow_args["name"],
                name=workflow_args["name"],
                account_id=workflow_args.get("account_id", None),
                enabled=workflow_args.get("enabled", True),
                muting_rules_handling=workflow_args.get("muting_rules_handling", None),
                issues_filter=pulumi_newrelic.WorkflowIssuesFilterArgs(
                    name=workflow_args["issues_filter"].get("name"),
                    type=workflow_args["issues_filter"].get("type"),
                    # https://github.com/NRUG-SRE/terraform-newrelic-sample/blob/56fc31d1abb5d744ee3d27d01bda7816650e12b9/terraform/newrelic/workflows.tf#L38
                    predicates=[
                        pulumi_newrelic.WorkflowIssuesFilterPredicateArgs(
                            **predicate,
                        )
                        for predicate in workflow_args["issues_filter"]["predicates"]
                    ],
                ),
                destinations=[
                    pulumi_newrelic.WorkflowDestinationArgs(
                        channel_id=self.notification_channels_dict[destination["channel_name"]].id,
                        notification_triggers=destination["notification_triggers"],
                    )
                    for destination in workflow_args["destinations"]
                ],
                opts=pulumi.ResourceOptions(parent=self),
            )
