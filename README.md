# Auto-reboot a Netgear CM1200 cable modem from macOS
 Automate rebooting a Netgear CM1200 cable modem with macOS Calendar event

# Steps
1. Open Automator
2. Choose Workflow
3. Select Utilities and then double-click "Run Shell Script"
4. Paste in the cm1200-reboot bash/zsh script
5. File -> Save... -> select Application type, name it reboot-cm1200.app
6. Open Calendar
7. New Event
8. [choose your schedule; i chose to run it daily]
9. Set Alert:
10.   - Custom
11.   - Open File
12.   - Other...
13.   - [choose reboot-cm1200.app]
14.   - OK
