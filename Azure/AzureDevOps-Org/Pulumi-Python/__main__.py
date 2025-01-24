import pulumi
import pulumi_azuredevops

config = pulumi.Config()

var_pipeline_project_name = config.require("pipeline_project_name")
dat_pipeline_project = pulumi_azuredevops.get_project(name=var_pipeline_project_name)

out_build_defs_url = {}
var_org_url = pulumi.Config("azuredevops").require("orgServiceUrl")
var_build_defs = config.require_object("build_defs")
for each_value in var_build_defs:
    dat_git_project = pulumi_azuredevops.get_project(
        name=each_value["build_def"]["repo"]["project_name"]
    )
    dat_git_repo = pulumi_azuredevops.get_git_repository(
        name=each_value["build_def"]["repo"]["repo_name"], project_id=dat_git_project.id
    )
    res_build_def = pulumi_azuredevops.BuildDefinition(
        each_value["iac_id"],
        project_id=dat_pipeline_project.id,
        name=each_value["build_def"]["name"],
        path=each_value["build_def"].get("path", None),
        ci_trigger={
            "use_yaml": True,
        },
        repository={
            "repo_type": "TfsGit",
            "repo_id": dat_git_repo.id,
            "branch_name": each_value["build_def"]["repo"]["branch_name"],
            "yml_path": each_value["build_def"]["repo"]["yml_path"],
        },
        variables=[
            pulumi_azuredevops.BuildDefinitionVariableArgs(**variable)
            for variable in each_value["build_def"].get("variables", [])
        ],
    )
    out_build_defs_url[each_value["build_def"]["name"]] = pulumi.Output.all(
        def_id=res_build_def.id
    ).apply(
        lambda args: f"{var_org_url}/{var_pipeline_project_name}/_build?definitionId={args['def_id']}"
    )

pulumi.export("build_defs_url", out_build_defs_url)
