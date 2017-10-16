#!/bin/bash

# Setup error handling
set -e
set -o pipefail

# Enable debugging
#set -x

# Function for uninstalling an existing fix
function uninstallFix()
{
	echo "Checking if fix already exists.."

	if [ -f "$HOME/Library/LaunchAgents/com.github.dids.intelquicksync-itunes-fix.plist" ]; then
		echo "Unloading and removing existing launch agent.."
		launchctl unload "$HOME/Library/LaunchAgents/com.github.dids.intelquicksync-itunes-fix.plist"
		rm -f "$HOME/Library/LaunchAgents/com.github.dids.intelquicksync-itunes-fix.plist"
	fi

	if [ -d "$HOME/Library/Scripts/intelquicksync-itunes-fix" ]; then
		echo "Removing existing scripts.."
		rm -fr "$HOME/Library/Scripts/intelquicksync-itunes-fix"
	fi
}

# Function for installing the fix
function installFix()
{
	echo "Installing fix.."

	# Install the launch agent
	cp -f com.github.dids.intelquicksync-itunes-fix.plist ~/Library/LaunchAgents/

	# Install scripts
	mkdir -p "$HOME/Library/Scripts/intelquicksync-itunes-fix"
	cp -f scripts/*.sh "$HOME/Library/Scripts/intelquicksync-itunes-fix/"
	chmod -R +x "$HOME/Library/Scripts/intelquicksync-itunes-fix/"

	# Load the launch agent
	launchctl load "$HOME/Library/LaunchAgents/com.github.dids.intelquicksync-itunes-fix.plist"
}

# Uninstall and install the fix
echo ""
uninstallFix
echo ""
installFix
echo ""
echo "Done."
