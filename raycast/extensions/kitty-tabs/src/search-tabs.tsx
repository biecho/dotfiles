import { Action, ActionPanel, List, Icon, showToast, Toast } from "@raycast/api";
import { useEffect, useState } from "react";
import { execSync } from "child_process";
import { existsSync, readdirSync } from "fs";

// ============================================================================
// Constants
// ============================================================================

const KITTY_BIN = "/opt/homebrew/bin/kitty";
const KITTY_SOCKET_DIR = "/tmp";
const KITTY_SOCKET_PREFIX = "kitty-";

const EMOJI = {
  LOCAL: "🏠",
  REMOTE: "🌍",
  FOCUSED: Icon.CheckCircle,
  TERMINAL: Icon.Terminal,
  GLOBE: Icon.Globe,
} as const;

// ============================================================================
// Types
// ============================================================================

interface KittyTab {
  id: number;
  title: string;
  cwd: string;
  isFocused: boolean;
  windowId: number;
  isSSH: boolean;
  sshHost?: string;
  remoteCwd?: string;
}

interface KittyWindow {
  id: number;
  title?: string;
  cwd?: string;
  is_focused: boolean;
  user_vars?: Record<string, string>;
  foreground_processes?: Array<{ cmdline?: string[] }>;
}

interface KittyOSWindow {
  id: number;
  tabs: Array<{
    windows: KittyWindow[];
  }>;
}

// ============================================================================
// Utility Functions
// ============================================================================

/**
 * Find the most recent Kitty control socket.
 * Kitty creates sockets with format: /tmp/kitty-<pid>
 */
function findKittySocket(): string | null {
  try {
    const files = readdirSync(KITTY_SOCKET_DIR).filter((f) => f.startsWith(KITTY_SOCKET_PREFIX));

    if (files.length === 0) {
      return null;
    }

    // Sort by modification time (most recent first)
    files.sort((a, b) => {
      const pathA = `${KITTY_SOCKET_DIR}/${a}`;
      const pathB = `${KITTY_SOCKET_DIR}/${b}`;

      if (!existsSync(pathA) || !existsSync(pathB)) {
        return 0;
      }

      const statA = require("fs").statSync(pathA);
      const statB = require("fs").statSync(pathB);
      return statB.mtimeMs - statA.mtimeMs;
    });

    return `${KITTY_SOCKET_DIR}/${files[0]}`;
  } catch (error) {
    console.error("Error finding Kitty socket:", error);
    return null;
  }
}

/**
 * Execute a Kitty remote control command.
 */
function executeKittyCommand(socket: string, command: string, args: string[] = []): string {
  const fullCommand = `${KITTY_BIN} @ --to "unix:${socket}" ${command} ${args.join(" ")}`;

  return execSync(fullCommand, {
    encoding: "utf-8",
    timeout: 5000,
  });
}

/**
 * Extract hostname from SSH command arguments.
 * Handles various SSH command formats:
 * - ssh hostname
 * - /usr/bin/ssh hostname
 * - ssh -o Option=value hostname
 * - ssh -- hostname
 * - kitten ssh hostname
 */
function extractSSHHostname(cmdline: string[]): string | null {
  if (!cmdline || cmdline.length === 0) {
    return null;
  }

  let startIdx = 0;
  const firstArg = cmdline[0];

  // Handle "kitten ssh" case
  if (firstArg === "kitten" && cmdline[1] === "ssh") {
    startIdx = 2;
  } else {
    startIdx = 1;
  }

  // Parse remaining arguments
  let skipNext = false;

  for (let i = startIdx; i < cmdline.length; i++) {
    const arg = cmdline[i];

    if (skipNext) {
      skipNext = false;
      continue;
    }

    // End of options marker
    if (arg === "--") {
      return cmdline[i + 1] || null;
    }

    // Flags that take an argument
    if (["-o", "-p", "-l", "-i", "-W"].includes(arg)) {
      skipNext = true;
      continue;
    }

    // Skip other flags and option=value pairs
    if (arg.startsWith("-") || arg.includes("=") || arg === "ssh") {
      continue;
    }

    // Found the hostname
    return arg;
  }

  return null;
}

/**
 * Check if a command is an SSH command.
 */
function isSSHCommand(cmdline: string[]): boolean {
  if (!cmdline || cmdline.length === 0) {
    return false;
  }

  const cmd = cmdline[0];
  return (
    cmd === "ssh" ||
    cmd.endsWith("/ssh") ||
    (cmd === "kitten" && cmdline[1] === "ssh")
  );
}

/**
 * Extract remote directory from window title.
 * Title format: "hostname: /path" or "hostname: ~/path"
 * Returns null if title contains a command (like "vi") instead of a path.
 */
function extractRemoteDirFromTitle(title: string): string | null {
  const match = title.match(/^[^:]+:\s*(.+)$/);

  if (!match) {
    return null;
  }

  const parsed = match[1].trim();

  // Only accept if it looks like a path (contains / or starts with ~)
  // This filters out commands like "vi", "htop", etc.
  if (parsed.includes("/") || parsed.startsWith("~")) {
    return parsed;
  }

  return null;
}

/**
 * Get the last path component from a directory path.
 */
function getShortPath(path: string): string {
  const parts = path.split("/");
  return parts[parts.length - 1] || path;
}

// ============================================================================
// Kitty Tab Management
// ============================================================================

/**
 * Fetch all tabs from Kitty.
 * Caches remote directories per window to handle full-screen apps.
 */
function getKittyTabs(socket: string, dirCache: Map<number, string>): KittyTab[] {
  try {
    const output = executeKittyCommand(socket, "ls");
    const data: KittyOSWindow[] = JSON.parse(output);
    const tabs: KittyTab[] = [];

    for (const osWindow of data) {
      for (const tab of osWindow.tabs) {
        for (const window of tab.windows) {
          const { isSSH, sshHost, remoteCwd } = parseWindowInfo(window, dirCache);

          tabs.push({
            id: window.id,
            title: window.title || "Untitled",
            cwd: window.cwd || "~",
            isFocused: window.is_focused,
            windowId: osWindow.id,
            isSSH,
            sshHost,
            remoteCwd,
          });
        }
      }
    }

    return tabs;
  } catch (error) {
    console.error("Error getting Kitty tabs:", error);
    throw new Error("Failed to get Kitty tabs");
  }
}

/**
 * Parse window information to determine SSH status and remote directory.
 */
function parseWindowInfo(
  window: KittyWindow,
  dirCache: Map<number, string>
): { isSSH: boolean; sshHost: string | null; remoteCwd: string | null } {
  let isSSH = false;
  let sshHost: string | null = null;
  let remoteCwd: string | null = null;

  // Check if this is an SSH session
  if (window.foreground_processes) {
    for (const proc of window.foreground_processes) {
      if (proc.cmdline && isSSHCommand(proc.cmdline)) {
        isSSH = true;
        sshHost = extractSSHHostname(proc.cmdline);
        break;
      }
    }
  }

  if (!isSSH) {
    return { isSSH: false, sshHost: null, remoteCwd: null };
  }

  // Try to get remote directory from various sources

  // 1. Shell integration (most reliable)
  if (window.user_vars?.PWD) {
    remoteCwd = window.user_vars.PWD;
  }

  // 2. Parse from window title (fallback)
  if (!remoteCwd && window.title) {
    remoteCwd = extractRemoteDirFromTitle(window.title);
  }

  // 3. Cache the directory if found
  if (remoteCwd) {
    dirCache.set(window.id, remoteCwd);
  }

  // 4. Use cached directory (for when running full-screen apps like vi)
  if (!remoteCwd && dirCache.has(window.id)) {
    remoteCwd = dirCache.get(window.id) || null;
  }

  return { isSSH, sshHost, remoteCwd };
}

/**
 * Focus a Kitty tab by window ID.
 */
function focusKittyTab(socket: string, windowId: number): void {
  try {
    executeKittyCommand(socket, "focus-window", [`--match`, `"id:${windowId}"`]);
  } catch (error) {
    console.error("Error focusing Kitty tab:", error);
    throw new Error("Failed to focus tab");
  }
}

// ============================================================================
// React Component
// ============================================================================

export default function Command() {
  const [tabs, setTabs] = useState<KittyTab[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [socket, setSocket] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [dirCache] = useState<Map<number, string>>(new Map());

  useEffect(() => {
    async function loadTabs() {
      try {
        setIsLoading(true);
        setError(null);

        const foundSocket = findKittySocket();
        if (!foundSocket) {
          setError("Kitty is not running or remote control is not enabled");
          setIsLoading(false);
          return;
        }

        setSocket(foundSocket);
        const kittyTabs = getKittyTabs(foundSocket, dirCache);
        setTabs(kittyTabs);
      } catch (err) {
        setError(err instanceof Error ? err.message : "Unknown error");
      } finally {
        setIsLoading(false);
      }
    }

    loadTabs();
  }, [dirCache]);

  async function handleFocusTab(tab: KittyTab) {
    if (!socket) return;

    try {
      focusKittyTab(socket, tab.id);
      await showToast({
        style: Toast.Style.Success,
        title: "Switched to tab",
        message: tab.title,
      });
    } catch (err) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Failed to switch tab",
        message: err instanceof Error ? err.message : "Unknown error",
      });
    }
  }

  if (error) {
    return (
      <List>
        <List.EmptyView icon={Icon.XMarkCircle} title="Could not connect to Kitty" description={error} />
      </List>
    );
  }

  return (
    <List isLoading={isLoading} searchBarPlaceholder="Search Kitty tabs...">
      {tabs.map((tab) => (
        <TabListItem key={tab.id} tab={tab} onFocus={handleFocusTab} />
      ))}
    </List>
  );
}

// ============================================================================
// Tab List Item Component
// ============================================================================

interface TabListItemProps {
  tab: KittyTab;
  onFocus: (tab: KittyTab) => void;
}

function TabListItem({ tab, onFocus }: TabListItemProps) {
  const { icon, subtitle, accessoryText, accessoryTooltip } = getTabDisplayInfo(tab);

  return (
    <List.Item
      icon={icon}
      title={tab.title}
      subtitle={subtitle}
      accessories={[{ text: accessoryText, tooltip: accessoryTooltip }]}
      actions={
        <ActionPanel>
          <Action title="Switch to Tab" icon={Icon.ArrowRight} onAction={() => onFocus(tab)} />
          {tab.isSSH && tab.remoteCwd && (
            <Action.CopyToClipboard
              title="Copy Remote Directory"
              content={tab.remoteCwd}
              shortcut={{ modifiers: ["cmd"], key: "c" }}
            />
          )}
          {tab.isSSH && !tab.remoteCwd && tab.sshHost && (
            <Action.CopyToClipboard
              title="Copy SSH Host"
              content={tab.sshHost}
              shortcut={{ modifiers: ["cmd"], key: "c" }}
            />
          )}
          {!tab.isSSH && (
            <Action.CopyToClipboard
              title="Copy Working Directory"
              content={tab.cwd}
              shortcut={{ modifiers: ["cmd"], key: "c" }}
            />
          )}
        </ActionPanel>
      }
    />
  );
}

/**
 * Calculate display information for a tab list item.
 */
function getTabDisplayInfo(tab: KittyTab) {
  const isLocal = !tab.isSSH;
  const locationEmoji = isLocal ? EMOJI.LOCAL : EMOJI.REMOTE;

  // Icon: checkmark if focused, globe if remote, terminal if local
  const icon = tab.isFocused ? EMOJI.FOCUSED : isLocal ? EMOJI.TERMINAL : EMOJI.GLOBE;

  // Subtitle: hostname for remote, short directory for local
  const subtitle = isLocal ? getShortPath(tab.cwd) : tab.sshHost || "remote";

  // Accessory: full path/directory with location emoji
  const accessoryText = isLocal ? tab.cwd : tab.remoteCwd || tab.sshHost || "remote";

  // Tooltip: context about what's shown
  const accessoryTooltip = (() => {
    if (isLocal) {
      return "Local Working Directory";
    }
    if (tab.remoteCwd) {
      return `Remote: ${tab.remoteCwd}`;
    }
    return "SSH Session";
  })();

  return {
    icon,
    subtitle,
    accessoryText: `${locationEmoji} ${accessoryText}`,
    accessoryTooltip,
  };
}
