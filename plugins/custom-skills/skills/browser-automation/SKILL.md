---
name: browser-automation
description: Browser automation tools - agent-browser CLI and chrome-devtools MCP. Use for web scraping, form automation, testing flows, performance analysis, and debugging. Triggers include "agent-browser", "chrome-devtools", "web scraping", "browser automation", "headless chrome", "performance trace", "Core Web Vitals".
---

# Browser Automation Tools

Two complementary tools for browser automation with different strengths.

## Tool Selection

| Need | Tool | Why |
|------|------|-----|
| **Fresh browser, scraping, testing** | agent-browser | Headless, parallel sessions, CLI-native |
| **DevTools features, performance** | chrome-devtools MCP | Core Web Vitals, network inspection, JS eval |
| **Existing Chrome session** | chrome-devtools MCP | Connects to your running browser |
| **Static content, docs** | WebFetch | No browser needed |

**Quick decision:**
- Need performance analysis or Core Web Vitals? → **chrome-devtools MCP**
- Need parallel sessions or bash scripting? → **agent-browser**
- Need to use your logged-in Chrome? → **chrome-devtools MCP**

---

# chrome-devtools MCP

Official Chrome DevTools team MCP for browser automation via DevTools Protocol. Connects to your running Chrome browser.

**Repo:** https://github.com/ChromeDevTools/chrome-devtools-mcp

## Quick Start

```
# MCP tools (use via Claude)
mcp__chrome-devtools__navigate_page     # Go to URL
mcp__chrome-devtools__take_snapshot     # Get a11y tree with uid refs
mcp__chrome-devtools__click             # Click element by uid
mcp__chrome-devtools__fill              # Fill input by uid
mcp__chrome-devtools__take_screenshot   # Capture page/element
```

## Key Capabilities

### Navigation & Interaction

| Tool | Purpose |
|------|---------|
| `navigate_page` | Go to URL, back, forward, reload |
| `take_snapshot` | Get accessibility tree with `uid` refs |
| `click` | Click element (supports dblClick) |
| `fill` | Type into input/textarea |
| `fill_form` | Fill multiple form fields at once |
| `hover` | Hover over element |
| `press_key` | Keyboard input ("Enter", "Control+A") |
| `drag` | Drag element to another |
| `upload_file` | Upload file through input |
| `handle_dialog` | Accept/dismiss browser dialogs |

### Page Management

| Tool | Purpose |
|------|---------|
| `list_pages` | See all open tabs |
| `select_page` | Switch to a tab |
| `new_page` | Open URL in new tab |
| `close_page` | Close a tab |
| `resize_page` | Set viewport dimensions |
| `wait_for` | Wait for text to appear |

### Performance Analysis (Unique to chrome-devtools)

| Tool | Purpose |
|------|---------|
| `performance_start_trace` | Start recording with optional reload |
| `performance_stop_trace` | Stop and get Core Web Vitals report |
| `performance_analyze_insight` | Deep dive into LCP, CLS, etc. |

**Example output includes:**
- LCP (Largest Contentful Paint) breakdown
- CLS (Cumulative Layout Shift) culprits
- Render-blocking resources
- Network dependency tree
- Caching recommendations

### Debugging

| Tool | Purpose |
|------|---------|
| `evaluate_script` | Run JavaScript in page context |
| `list_network_requests` | See all network activity |
| `get_network_request` | Get request details |
| `list_console_messages` | View console output |
| `get_console_message` | Get specific message |
| `take_screenshot` | Capture viewport or element |

### Emulation

| Tool | Purpose |
|------|---------|
| `emulate` | Set geolocation, network throttling, CPU throttling |

## Element References

Snapshots return elements with `uid` identifiers:

```
uid=1_0 RootWebArea "Example" url="https://example.com/"
  uid=1_1 heading "Title" level="1"
  uid=1_2 link "Click me" url="..."
  uid=1_3 textbox "Email"
```

Use `uid` values in interaction tools:
- `click` with `uid="1_2"`
- `fill` with `uid="1_3"` and `value="test@example.com"`

## Common Workflows

### Performance Audit

```
1. navigate_page to target URL
2. performance_start_trace with reload=true, autoStop=true
3. Review Core Web Vitals in response
4. performance_analyze_insight for specific issues (LCPBreakdown, CLSCulprits)
```

### Form Submission

```
1. navigate_page to form URL
2. take_snapshot to get element uids
3. fill_form with multiple elements
4. click submit button
5. wait_for confirmation text
```

### Debug Page Issues

```
1. navigate_page to problem URL
2. list_console_messages to check for errors
3. list_network_requests to find failed requests
4. evaluate_script to inspect DOM state
```

---

# agent-browser CLI

Fast CLI for browser automation, optimized for AI agents. Vercel Labs project.

## Quick Start

```bash
agent-browser open <url>        # Navigate to page
agent-browser snapshot -i       # Get interactive elements with refs (@e1, @e2)
agent-browser click @e1         # Interact using refs
agent-browser close             # Close browser
```

Re-snapshot after page changes. Use `--headed` for debugging.

---

## By Use Case

### Web Scraping

```bash
# Basic scrape
agent-browser open https://example.com/products
agent-browser snapshot -i
agent-browser get text @e5              # Get element text

# Parallel scraping with sessions
agent-browser --session site1 open https://store1.com &
agent-browser --session site2 open https://store2.com &
wait
agent-browser --session site1 snapshot -i
agent-browser --session site2 snapshot -i
```

### Form Automation

```bash
agent-browser open https://example.com/signup
agent-browser snapshot -i
agent-browser fill @e3 "user@example.com"   # Email
agent-browser fill @e4 "password123"        # Password
agent-browser click @e5                     # Submit
agent-browser wait --load networkidle       # Wait for response
```

### Testing Flows

```bash
# Login flow test
agent-browser open https://app.example.com/login
agent-browser fill @e1 "test@test.com"
agent-browser fill @e2 "testpass"
agent-browser click @e3
agent-browser wait --url "**/dashboard"     # Verify redirect
agent-browser screenshot login-success.png
```

### Multi-Tab Workflows

```bash
agent-browser open https://example.com
agent-browser tab new https://docs.example.com
agent-browser tab list                      # See all tabs
agent-browser tab 1                         # Switch to tab 1
agent-browser tab close                     # Close current tab
```

---

## Command Reference

### Snapshot & Element Selection

```bash
# Snapshot options
agent-browser snapshot                      # Full accessibility tree
agent-browser snapshot -i                   # Interactive elements only
agent-browser snapshot -c                   # Compact (remove empty elements)
agent-browser snapshot -d 3                 # Limit depth to 3 levels
agent-browser snapshot -s ".main"           # Scope to CSS selector
agent-browser snapshot -i --json            # JSON output for parsing

# Element refs from snapshot
@e1, @e2, @e3...                            # Use these in commands
```

### Navigation & Interaction

```bash
# Navigation
agent-browser open <url>
agent-browser back / forward / reload

# Clicking
agent-browser click @e1
agent-browser dblclick @e1

# Text input
agent-browser fill @e3 "text"               # Clear + fill
agent-browser type @e3 "text"               # Append text
agent-browser press Enter                   # Key press
agent-browser press Control+a               # Key combo

# Forms
agent-browser select @e5 "option-value"     # Dropdown
agent-browser check @e6                     # Checkbox on
agent-browser uncheck @e6                   # Checkbox off
agent-browser upload @e7 file1.pdf file2.pdf

# Mouse
agent-browser hover @e1
agent-browser focus @e1
agent-browser drag @e1 @e2
agent-browser mouse move 100 200
agent-browser mouse wheel 500               # Scroll

# Scrolling
agent-browser scroll down 500
agent-browser scroll up 300
agent-browser scrollintoview @e8
```

### Semantic Element Finding

Find elements without refs (when snapshot doesn't give what you need):

```bash
agent-browser find role button click            # By ARIA role
agent-browser find text "Submit" click          # By visible text
agent-browser find label "Email" fill "a@b.com" # By label
agent-browser find placeholder "Search" fill x  # By placeholder
agent-browser find testid submit-btn click      # By data-testid
agent-browser find title "Help" click           # By title attribute
```

### Get Info & State Checks

```bash
# Extract data
agent-browser get text @e1                  # Element text
agent-browser get html @e1                  # Element HTML
agent-browser get value @e1                 # Input value
agent-browser get attr href @e1             # Attribute value
agent-browser get title                     # Page title
agent-browser get url                       # Current URL
agent-browser get count ".item"             # Element count
agent-browser get box @e1                   # Bounding box

# State checks
agent-browser is visible @e1
agent-browser is enabled @e1
agent-browser is checked @e1
```

### Wait Operations

```bash
agent-browser wait @e1                      # Wait for element
agent-browser wait 2000                     # Wait milliseconds
agent-browser wait --text "Success"         # Wait for text
agent-browser wait --url "**/dashboard"     # Wait for URL pattern
agent-browser wait --load networkidle       # Wait for network idle
agent-browser wait --load domcontentloaded
agent-browser wait --load load
```

---

## Advanced Features

### Sessions (Isolated Instances)

Run multiple browsers in parallel with separate state:

```bash
# Named sessions
agent-browser --session work open example.com
agent-browser --session personal open gmail.com

# List active sessions
agent-browser session list

# Via environment variable
AGENT_BROWSER_SESSION=test agent-browser open url
```

### Network Interception

Mock APIs, block requests, track network:

```bash
# Mock API response
agent-browser network route "**/api/users" --body '{"users":[]}'

# Block requests (ads, analytics)
agent-browser network route "**/analytics/*" --abort
agent-browser network route "**/ads/*" --abort

# View tracked requests
agent-browser network requests
agent-browser network requests --filter api

# Remove routes
agent-browser network unroute              # Remove all
agent-browser network unroute "**/api/*"   # Remove specific
```

### Storage & Cookies

```bash
# Cookies
agent-browser cookies get
agent-browser cookies set '{"name":"session","value":"abc123"}'
agent-browser cookies clear

# Web storage
agent-browser storage local get
agent-browser storage local set key value
agent-browser storage local clear
agent-browser storage session get
agent-browser storage session set key value
```

### Debug & Recording

```bash
# Trace recording (for debugging)
agent-browser trace start
# ... do actions ...
agent-browser trace stop trace.zip         # Save Playwright trace

# View logs
agent-browser console                       # Console output
agent-browser console --clear
agent-browser errors                        # Page errors
agent-browser errors --clear

# Visual debugging
agent-browser highlight @e1                 # Highlight element
agent-browser --headed open url             # Show browser window
```

### Browser Settings

```bash
# Viewport
agent-browser set viewport 1920 1080

# Device emulation
agent-browser set device "iPhone 14"
agent-browser set device "iPad Pro"

# Color scheme
agent-browser set media dark
agent-browser set media light

# Geolocation
agent-browser set geo 37.7749 -122.4194

# Offline mode
agent-browser set offline on
agent-browser set offline off

# HTTP headers (scoped to origin)
agent-browser --headers '{"Authorization":"Bearer token"}' open url

# Basic auth
agent-browser set credentials username password
```

### Screenshots & PDF

```bash
agent-browser screenshot                    # Current viewport
agent-browser screenshot page.png           # Save to file
agent-browser screenshot --full page.png    # Full page
agent-browser pdf output.pdf                # Save as PDF
```

### CDP Connection

Connect to existing browser via Chrome DevTools Protocol:

```bash
# Start Chrome with remote debugging
google-chrome --remote-debugging-port=9222

# Connect agent-browser
agent-browser --cdp 9222 open url
agent-browser --cdp 9222 snapshot -i
```

### Browser Extensions

```bash
agent-browser --extension ./my-extension open url
agent-browser --extension ./ext1 --extension ./ext2 open url
```

---

## Environment Variables

```bash
AGENT_BROWSER_SESSION=name          # Default session name
AGENT_BROWSER_EXECUTABLE_PATH=path  # Custom browser binary
AGENT_BROWSER_STREAM_PORT=9223      # WebSocket viewport streaming
```

---

## Common Patterns

### Login + Action

```bash
agent-browser open https://app.example.com/login
agent-browser snapshot -i
agent-browser fill @e1 "$EMAIL"
agent-browser fill @e2 "$PASSWORD"
agent-browser click @e3
agent-browser wait --url "**/dashboard"
agent-browser snapshot -i
# ... continue with logged-in actions
```

### Scrape with Pagination

```bash
agent-browser open https://example.com/products?page=1
while true; do
  agent-browser snapshot -i
  # Extract data from current page
  agent-browser get text ".product-name"
  # Try to click next, break if not found
  agent-browser click "[aria-label='Next']" || break
  agent-browser wait --load networkidle
done
```

### Parallel Session Scraping

```bash
# Start multiple sessions
for i in 1 2 3 4 5; do
  agent-browser --session "s$i" open "https://example.com/page/$i" &
done
wait

# Collect results
for i in 1 2 3 4 5; do
  agent-browser --session "s$i" snapshot -i --json >> results.json
  agent-browser --session "s$i" close
done
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Element not found | Re-snapshot after page changes |
| Timeout on wait | Increase timeout or check selector |
| Headless blocked | Try `--headed` or different user-agent |
| Session conflict | Use unique `--session` names |
| Network route not working | Check URL pattern (glob syntax) |

## Installation

```bash
npm install -g agent-browser
agent-browser install                       # Download Chromium
agent-browser install --with-deps           # Linux: also install system deps
```
