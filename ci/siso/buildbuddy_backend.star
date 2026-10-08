# SANDFOX BuildBuddy REAPI backend configuration.
#
# This file is installed into the external Chromium workspace only when
# AFTERBIRD_REMOTE_EXEC=1. It intentionally starts with OSFamily only:
# the successful SANDFOX probe proved BuildBuddy can execute a real Chromium
# compile action with this platform constraint. Add worker/container
# properties only when a real Chromium build demonstrates the need.

load("@builtin//struct.star", "module")

def __platform_properties(ctx):
    return {
        "default": {
            "OSFamily": "Linux",
        },
        "large": {
            "OSFamily": "Linux",
        },
    }

backend = module(
    "backend",
    platform_properties = __platform_properties,
)
