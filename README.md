# TimeLime 🍋

A beautiful event tracker and habit tracker available as both a web app and a native macOS menu bar application.

## 📦 Project Structure

This repository contains two applications:

- **[web-app/](web-app/)** - Svelte web application deployed on GitHub Pages
- **[macos-app/](macos-app/)** - Native macOS menu bar app built with SwiftUI

Both apps share the same core functionality with platform-specific optimizations.

## 🌟 Features

- **Event Management**: Create, edit, and delete events with customizable properties
- **Multiple Calendar Views**:
  - Gantt Chart (yearly timeline view)
  - Monthly Calendar
  - Weekly Calendar
- **Flexible Check-ins**: Track progress with daily, weekly, monthly, yearly, or custom check-ins
- **GitHub-style Progress Grid**: Visualize your consistency with a contribution calendar
- **Data Persistence**:
  - Web: Browser cookies
  - macOS: Local file storage
- **Export/Import**: Backup and restore your data in JSON format
- **Beautiful UI**:
  - Web: Responsive design with dark theme
  - macOS: Native macOS design following Apple HIG

## 🚀 Getting Started

### Web App

🌐 **Live Demo**: [https://djock.github.io/timelime/](https://djock.github.io/timelime/)

#### Development

```bash
cd web-app
npm install
npm run dev
```

See [web-app/README.md](web-app/README.md) for more details.

### macOS App

🍎 **Requirements**: macOS 13.0 (Ventura) or later

#### Development

1. Open `macos-app/TimeLime.xcodeproj` in Xcode
2. Build and run (⌘R)

The app runs in the menu bar - click the calendar icon to open the dropdown.

See [macos-app/README.md](macos-app/README.md) for more details.

## 🛠️ Tech Stack

### Web App
- **Framework**: Svelte 4
- **Build Tool**: Vite 5
- **Styling**: Custom CSS with CSS variables
- **Storage**: Browser Cookies
- **Hosting**: GitHub Pages
- **CI/CD**: GitHub Actions

### macOS App
- **Framework**: SwiftUI
- **Language**: Swift 5
- **Architecture**: MVVM
- **Storage**: Local file system
- **Deployment Target**: macOS 13.0+

## 📝 Usage

1. **Add an Event**: Click the "New Event" button to create a new event
2. **Configure Event**: Set the title, start/end dates, and check-in frequency
3. **Check In**: Open an event and click the check-in button to mark your progress
4. **Switch Views**: Use the view buttons to switch between Gantt, Monthly, and Weekly views
5. **Export Data**: Click "Export" to download your data as JSON
6. **Import Data**: Click "Import" to restore data from a previous export

## 🎨 Features in Detail

### Event Types
- Daily check-ins: 365 squares (366 for leap years)
- Weekly check-ins: 52-53 squares
- Monthly check-ins: 12 squares
- Yearly check-ins: 1 square per year

### Progress Visualization
- ✅ Green: Successfully checked in
- ❌ Red: Missed check-in
- ⏳ Gray: Future/upcoming

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
