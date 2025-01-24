## Prepare runtime
0. Create poetry `pyproject.toml` from scratch
```powershell
$name="pki"
poetry init --name $name
```
1. Prepare poetry venv
```powershell
poetry env use python
```
or use existing poetry venv
```powershell
poetry env use "C:\Users\<username>\AppData\Local\pypoetry\Cache\virtualenvs\pki-xxx-py3.11\Scripts\python.exe"
```

## prepare pulumi
0. Create new pulumi project from scratch, below command will create pulumi project with `python` language, `poetry` as python package manager
```powershell
$lang="python"
$toolchain="poetry"
$name="pki"
pulumi new `
    $lang `
    --name $name `
    --secrets-provider=passphrase `
    --offline `
    --runtime-options toolchain=$toolchain `
    --stack default `
    --force
```

1. Config pulumi backend, in this case, we use local backend  
set backend in `Pulumi.yaml`
ref:
- https://www.pulumi.com/docs/concepts/state/#logging-into-and-out-of-state-backends
- https://www.pulumi.com/docs/concepts/state/#local-filesystem
```yaml
backend:
  url: file://.
```

2. Login pulumi, which means connect to backend, similar to `terraform init`
```powershell
pulumi login
```

3. to create new stack, aka `terraform workspace new`  
ref: https://www.pulumi.com/docs/cli/commands/pulumi_stack_init/
```powershell
pulumi stack init default --secrets-provider passphrase
```

## development
1. add pulumi related packages
```powershell
poetry add pulumi
poetry add pulumi-xxx
```

4. Preview, aka `terraform plan`
```powershell
$env:PULUMI_CONFIG_PASSPHRASE = "P@ssw0rd"
pulumi preview --stack default
```