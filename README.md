# boiler-aws-template

## dir & files explaination

1. `base` is a folder that usually contains basic templating use by automation
2. `base\auto.tf` to be softlink to each and every workspace, 1 single algorithm for resource creation/management for all workspaces
3. `setup.config` to define, tier setting for project and terraform version
    3.a. Tier 1, requires account 
    3.b. Tier 2, requires region and Tier 1
    3.c. Tier 3, requires group and Tier 1 and 2 requisites. 
    Each tier affects where the statefile store in s3 path
4. `.gitconfig` for some reason, git via `nerdctl` requires `safe.directory` settings, this is to override any git restrictions face by `nerdctl`
5. `tmp` is exempted from commiting to git. It purpose is to render temporary configs for template rendering
6. Run `tast --summary` to view the list of tasks that you can work with. 
