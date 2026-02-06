# Temporary Files Placement Rule

## Description
This custom instruction rule defines the location for all temporary files and outputs generated during RooCode tool usage. The purpose is to maintain a clean workspace by centralizing temporary data in a dedicated subdirectory outside the project workspace.

## Rules
- All generated temporary files and outputs must be placed in the `~/Workspace/tmp/roo` subdirectory.
- If the `~/Workspace/tmp/roo` subdirectory does not exist, tools should create it automatically before generating files.
- This rule applies to all RooCode tools that produce temporary or intermediate files.

- Note: `~/Workspace/tmp/roo` is a dedicated subfolder for RooCode temporary files within the general `~/Workspace/tmp/` directory.

## Documentation Access
- Documentation should be read from the `~/Workspace/docs` folder when available.
- Ensure to check the docs folder for relevant guides and instructions before proceeding with tasks.

## Devcontainer Context
- In devcontainer environments, the `~/Workspace` directory is mounted from the host, allowing persistence of tmp and docs folders across container restarts and sessions.
- This mounting ensures that temporary files and documentation are accessible both on the host and within the devcontainer.

## Examples
- When using a tool that generates a log file, save it to `~/Workspace/tmp/roo/log.txt`.
- For temporary build outputs, use `~/Workspace/tmp/roo/build/` as the output directory.
- Screenshot captures should be stored in `~/Workspace/tmp/roo/screenshots/`.