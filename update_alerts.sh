#!/bin/bash
# Home Assistant Alert System Updater
# Updates the alert system package + dashboard + blueprint + itself from GitHub
#
# Downloads are pinned to the exact commit that main points at right now,
# resolved through the GitHub API. raw.githubusercontent.com serves branch URLs
# ("/main/...") from a CDN cache that can lag a push by several minutes, so
# pulling straight after a commit can silently install the PREVIOUS version:
# wget returns 0, the file is valid YAML, and nothing looks wrong. A
# commit-pinned URL is immutable, so it can never be stale.
#
# Every download is also sanity-checked before it replaces a live file, and any
# failure on a critical file aborts with a non-zero exit instead of leaving a
# half-updated install behind.

set -u

REPO="BackyardBird/ha-alert-system"
UA="ha-alert-system-updater"

fail() { echo "❌ $*" >&2; exit 1; }

echo "Updating Home Assistant Alert System..."

########################
# Resolve the commit to install
########################
REF=$(wget -qO- --header="User-Agent: $UA" \
        "https://api.github.com/repos/$REPO/commits/main" 2>/dev/null \
      | head -c 400 | grep -oE '[0-9a-f]{40}' | head -1)

if [ -n "$REF" ]; then
    echo "📌 Pinned to commit $REF"
else
    REF="main"
    echo "⚠️  Could not reach the GitHub API - falling back to the 'main' branch."
    echo "    The CDN may serve a copy a few minutes behind the latest commit."
fi

BASE="https://raw.githubusercontent.com/$REPO/$REF"

########################
# Download helper
#   fetch <repo path> <destination> <string the file must contain> <critical>
########################
fetch() {
    src="$BASE/$1"
    dest="$2"
    must="$3"
    critical="$4"
    tmp="$dest.tmp"

    if ! wget -qO "$tmp" --header="User-Agent: $UA" "$src"; then
        rm -f "$tmp"
        [ "$critical" = "yes" ] && fail "Download failed: $src"
        echo "⚠️  Download failed (non-critical): $src"
        return 1
    fi

    # Guards against a truncated transfer or an error page saved as content
    if [ ! -s "$tmp" ] || ! grep -q "$must" "$tmp"; then
        rm -f "$tmp"
        [ "$critical" = "yes" ] && fail "Sanity check failed for $src - live file left untouched"
        echo "⚠️  Sanity check failed (non-critical): $src"
        return 1
    fi

    if [ -f "$dest" ] && cmp -s "$dest" "$tmp"; then
        rm -f "$tmp"
        echo "✅ Already current: $dest"
        return 0
    fi

    if [ -f "$dest" ]; then
        cp "$dest" "$dest.backup.$(date +%Y%m%d_%H%M%S)" \
            && echo "🗄  Backed up $dest"
    fi
    mv "$tmp" "$dest" || fail "Could not replace $dest"
    echo "✅ Updated $dest"
}

########################
# Self-update
########################
if [ "${ALERTS_SELFUPDATED:-}" != "1" ]; then
    echo "Checking for update script changes..."
    selftmp="/config/update_alerts.sh.tmp"
    if wget -qO "$selftmp" --header="User-Agent: $UA" "$BASE/update_alerts.sh" \
       && [ -s "$selftmp" ] \
       && grep -q "Home Assistant Alert System Updater" "$selftmp"; then
        if cmp -s /config/update_alerts.sh "$selftmp"; then
            rm -f "$selftmp"
            echo "Update script is current."
        else
            mv "$selftmp" /config/update_alerts.sh
            chmod +x /config/update_alerts.sh
            echo "Update script was updated. Re-running..."
            # Pass the resolved commit down so the new run does not re-resolve
            # (and cannot land on a different commit mid-update)
            export ALERTS_SELFUPDATED=1
            exec /config/update_alerts.sh
        fi
    else
        rm -f "$selftmp"
        echo "Could not check for script updates (non-critical)."
    fi
fi

########################
# Update the tracked files
########################
mkdir -p /config/packages /config/lovelace /config/blueprints/automation/alert_system

fetch "packages/alert_system.yaml" \
      "/config/packages/alert_system.yaml" \
      "^# packages/alert_system.yaml" yes

fetch "lovelace/alert_system_dash.yaml" \
      "/config/lovelace/alert_system_dash.yaml" \
      "^title: Alert System" yes

fetch "blueprints/automation/alert_system/send_alert.yaml" \
      "/config/blueprints/automation/alert_system/send_alert.yaml" \
      "^blueprint:" no

########################
# Report what actually landed
########################
VER=$(grep -m1 '^# Version:' /config/packages/alert_system.yaml 2>/dev/null | sed 's/^# Version: *//')
echo ""
echo "📦 Installed version: ${VER:-unknown}"
echo "📌 From commit:       $REF"
echo ""
echo "🔄 Restart Home Assistant to apply changes"
echo "   A restart (not just a reload) is needed when this update adds helpers"
echo "   or other new entities."
echo ""
echo "   Verify afterwards - a clean 'ha core check' does NOT prove the entities"
echo "   loaded. Check a few directly, e.g. sensor.threshold_alert_status."
