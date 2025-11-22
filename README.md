# TimeLime 🍋

A beautiful event tracker and habit tracker web app with calendar views and GitHub contribution-style check-in visualization.

## 🌟 Features

- **Event Management**: Create, edit, and delete events with customizable properties
- **Multiple Calendar Views**:
  - Gantt Chart (yearly timeline view)
  - Monthly Calendar
  - Weekly Calendar
- **Flexible Check-ins**: Track progress with daily, weekly, monthly, or yearly check-ins
- **GitHub-style Progress Grid**: Visualize your consistency with a contribution calendar
- **Data Persistence**: All data stored in cookies for automatic persistence
- **Export/Import**: Backup and restore your data in JSON format
- **Responsive Design**: Works beautifully on desktop and mobile devices
- **Dark Theme**: Easy on the eyes with a lime-green accent color

## 🚀 Live Demo

Visit the live app at: [https://djock.github.io/timelime/](https://djock.github.io/timelime/)

## 💻 Development

### Prerequisites

- Node.js 18 or higher
- npm

### Installation

```bash
# Clone the repository
git clone https://github.com/djock/timelime.git
cd timelime

# Install dependencies
npm install

# Start development server
npm run dev
```

### Build

```bash
# Build for production
npm run build

# Preview production build
npm run preview
```

## 📦 Deployment

The app is automatically deployed to GitHub Pages when changes are pushed to the main branch via GitHub Actions.

### Setup Instructions

1. Go to your repository settings on GitHub
2. Navigate to **Settings > Pages**
3. Under **Source**, select **GitHub Actions**
4. The workflow will automatically deploy on push to main

## 🛠️ Tech Stack

- **Framework**: Svelte 4
- **Build Tool**: Vite 5
- **Styling**: Custom CSS with CSS variables
- **Storage**: Browser Cookies
- **Hosting**: GitHub Pages
- **CI/CD**: GitHub Actions

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
