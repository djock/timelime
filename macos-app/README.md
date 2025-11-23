# TimeLime macOS App

A native macOS menu bar application for habit and event tracking, built with SwiftUI.

## Features

- 🍏 Native macOS menu bar app (like Itsycal)
- 📅 Multiple calendar views (Gantt chart, Monthly, Weekly)
- ✅ Track events with customizable check-in frequencies
- 💾 Local data storage using the file system
- 📊 Real-time statistics and streak tracking
- 📤 Export/Import data as JSON
- 🎨 Follows Apple Human Interface Guidelines
- 🔒 App Sandbox enabled for security

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (for development)

## Installation

### From Xcode

1. Open `TimeLime.xcodeproj` in Xcode
2. Select your signing team in the project settings
3. Build and run the project (⌘R)

### Building for Distribution

1. Open the project in Xcode
2. Archive the project (Product → Archive)
3. Distribute the app using the Xcode Organizer

## Usage

### First Launch

1. The TimeLime icon will appear in your menu bar (calendar icon)
2. Click the icon to open the app dropdown
3. Add your first event using the "+" button

### Managing Events

- **Add Event**: Click the "+" button in the header
- **Edit Event**: Click on an event in any view
- **Delete Event**: Open the event form and click "Delete"

### Check-ins

- **Monthly View**: Click on any day to toggle check-in
- **Weekly View**: Click on any cell to toggle check-in
- **Gantt View**: Visual overview of all events

### Data Management

- **Export Data**: Click the export icon and choose a location
- **Import Data**: Click the import option and select a JSON file
- **Clear Data**: Use with caution - removes all events

## Project Structure

```
macos-app/
├── TimeLime.xcodeproj/         # Xcode project
└── TimeLime/
    ├── TimeLimeApp.swift       # App entry point with menu bar setup
    ├── MenuBarController.swift # Menu bar management
    ├── Models/
    │   ├── Event.swift         # Event data model
    │   └── StorageManager.swift # Local storage management
    ├── Views/
    │   ├── ContentView.swift   # Main container view
    │   ├── EventFormView.swift # Event creation/editing
    │   ├── GanttView.swift     # Yearly timeline view
    │   ├── MonthlyView.swift   # Monthly calendar view
    │   └── WeeklyView.swift    # Weekly grid view
    ├── ViewModels/
    │   └── EventViewModel.swift # Business logic
    ├── Utils/
    │   └── DateUtils.swift     # Date utility functions
    └── Assets.xcassets/        # App icons and colors
```

## Data Storage

Event data is stored locally in:
```
~/Library/Application Support/TimeLime/events.json
```

The data is automatically saved after each modification.

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures (Event, CheckIn)
- **Views**: SwiftUI views for the UI
- **ViewModels**: Business logic and state management
- **Utils**: Helper functions and utilities

## Menu Bar Behavior

The app runs as a menu bar application (LSUIElement = YES), meaning:
- No dock icon
- Lightweight and unobtrusive
- Always accessible from the menu bar
- Popover closes automatically when clicking outside

## Design Philosophy

The macOS app follows Apple's Human Interface Guidelines:
- Native macOS controls and styling
- Keyboard shortcuts support
- Dark mode compatibility
- Sandboxed for security
- Optimized for menu bar usage

## Known Limitations

- Currently does not sync with the web app
- Import merges data (does not replace)
- Menu bar icon uses SF Symbols (system icon)

## Future Enhancements

- [ ] iCloud sync between devices
- [ ] Custom menu bar icon
- [ ] Notifications for check-in reminders
- [ ] Widgets support
- [ ] Shortcuts integration
- [ ] Apple Watch companion app

## License

MIT
