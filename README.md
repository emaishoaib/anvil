# Anvil

Everyday Mac tools in one app that lives in your menu bar.

Instead of a separate app for each small job, Anvil has one search bar to reach them and one place for their settings. It runs in the background with an anvil in the menu bar and no Dock icon.

## What it does

**Settings** -- every setting lives in the search bar as a grid of the tools or found by name as you type. Any tool but the search bar can be turned off.

**Search bar** -- a bar near the top of the screen that opens over whatever app is in front, which strikes the anvil in the menu bar like a hammer as it opens. It finds apps and quick links as you type, and the apps you open most rise to the top. Typing a command's name such as `define`, `link`, `settings`, `uninstall` or `ai` opens that tool inside the bar, which you can pin so it stays open while you work in other apps. Close the bar and open it again soon and it comes back as you left it with the same page and text (for as long as you set in its settings). Opening an app or a quick link starts it fresh instead and a chat with Claude always comes back however long the bar was closed.

**Quick answers** -- the bar answers some things without opening anything like sums, unit conversions, currency conversions and dates. Typing `define` looks a word up in the Mac's own dictionary.

**Quick links** -- a quick link is a named web address opened from the bar like an app. A link can hold up to three placeholders such as a search query. Each link can open in an app of your choosing rather than the default browser. Links can be exported to a file and imported again.

**Switcher** -- switches between every window on the current Space rather than every app, or only between the windows of the app in front. Windows are listed by how recently you used them and that order is kept when Anvil restarts. It started as [Hop](https://github.com/emaishoaib/hop), a standalone window switcher.

**Windows** -- snaps the window in front to halves, thirds, corners or the whole screen, either from a shortcut or by dragging it to the edge of the screen.

**Rules** -- do something when something happens like choosing a menu item from a mouse button or quitting an app when another one opens. A rule can work in every app or only in the ones you pick.

**Key swaps** -- trades two keys on the Mac's built-in keyboard and leaves an external keyboard as it is.

**Shell** -- keeps your zsh aliases, startup lines and prompt in Anvil and writes them to a zsh file that `~/.zshrc` loads, then the next terminal you open picks up any change you made in the bar.

**Mouse** -- makes a plain mouse wheel scroll smoothly like a trackpad. Logitech mice also get their speed, wheel and extra buttons set from Anvil.

**Keep Awake** -- keeps the Mac from sleeping for a while, even with the lid closed if you want.

**AI** -- turns the bar into a chat with Claude Code about a folder you pick and asks you before Claude runs a command or makes a change. A chat can be saved into Claude desktop, and any Claude desktop Code session can be carried on from the bar. From any app, the listening shortcut, Option Shift Space by default, listens until it is pressed again, then sends what you said to the last session and shows it in the bar. Starting with "new session" starts a new one instead, and starting with "last session" says so outright. Speech is turned into text on the Mac.

**Uninstaller** -- removes an app along with the files it leaves across the Mac. You untick anything you want to keep and the rest goes to the Trash, so a mistake can be undone.

**At a glance** -- the bar's footer shows whether Keep Awake is on and how full your Logitech and AirPods batteries are.

## How it works

**Permissions** -- what Anvil asks for and why:

- **Accessibility** -- to see keys and mouse buttons and move other apps' windows
- **Full Disk Access** -- for the Uninstaller to find every leftover
- **Bluetooth** -- to read AirPods batteries
- **Administrator password** -- when uninstalling an app from the Mac App Store or keeping the Mac awake with the lid closed

**Where settings are kept** -- rules, key swaps, mouse settings and the shell setup can live as files in a folder you choose such as one that syncs between Macs.

**What reaches the internet** -- only a few places and only for these things:

- **Currency rates** -- downloaded from a free public exchange rate service at most twice a day then kept on the Mac
- **Quick link icons** -- each quick link's icon is fetched from its own website then kept on the Mac
- **Updates** -- Anvil checks its own website for new versions

**Where AI chats run** -- a chat runs through Claude Code on the Mac and your Claude account, so what you type goes to Anthropic the same way it would from a terminal. Each chat is a Claude Code session kept where Claude Code keeps all its sessions.

**Your zshrc** -- turning the Shell tool on adds a small block to `~/.zshrc` that loads Anvil's zsh file and turning it off takes the block out again. Anvil never touches the rest of the file and leaves it alone if it can't read it.

**AirPods batteries** -- macOS doesn't publish each earbud's battery so Anvil reads properties Apple doesn't document and a macOS update could stop them showing.

## Requirements

- **macOS 27** -- to run Anvil
- **Xcode 27** -- to build it
- **Sparkle** -- installs updates and is the only third-party dependency
- **[Claude Code](https://claude.com/claude-code)** -- for the AI tool

## Building

The Xcode project is generated from `project.yml` using `xcodegen` and isn't committed, and neither is `Config/Release.xcconfig` which holds the Apple development team, the updates host and the Sparkle public key for release builds. Make it by copying `Config/Release.xcconfig.example` and filling it in.

To try a change type `go` anywhere in this repo and pick Rebuild to:

1. Build Anvil in Release
2. Quit the running Anvil
3. Install the new build in `/Applications`
4. Reopen it

The `go` command, its menu and its scripts all come from a private repo shared by all my apps, and the menu needs [gum](https://github.com/charmbracelet/gum) which the private repo installs.

## Releasing

Anvil is released as a DMG from its own website and installed copies update themselves through Sparkle.
