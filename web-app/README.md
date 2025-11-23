# TimeLime Web App

A habit and event tracker web application built with Svelte and Vite.

## Features

- 📅 Multiple calendar views (Gantt chart, Monthly, Weekly)
- ✅ Track events with customizable check-in frequencies (daily, weekly, monthly, yearly, custom)
- 📊 Visualize progress with GitHub-style contribution grids
- 💾 Local data persistence using browser cookies
- 📱 Responsive mobile design
- 🌙 Dark theme with lime-green accent
- 📤 Export/Import data as JSON

## Tech Stack

- **Framework**: Svelte 4
- **Build Tool**: Vite 5
- **Styling**: CSS3 with CSS variables
- **Storage**: Browser Cookies
- **Deployment**: GitHub Pages

## Development

### Prerequisites

- Node.js 20 or higher
- npm

### Getting Started

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start the development server:
   ```bash
   npm run dev
   ```

3. Open your browser to `http://localhost:5173`

### Build for Production

```bash
npm run build
```

The built files will be in the `dist/` directory.

### Preview Production Build

```bash
npm run preview
```

## Project Structure

```
web-app/
├── src/
│   ├── App.svelte              # Main component
│   ├── app.css                 # Global styles
│   ├── main.js                 # Entry point
│   ├── components/             # Reusable components
│   │   ├── DateRangePicker.svelte
│   │   ├── EventModal.svelte
│   │   ├── EventPopup.svelte
│   │   ├── GanttView.svelte
│   │   ├── MonthlyView.svelte
│   │   └── WeeklyView.svelte
│   └── lib/                    # Utility modules
│       ├── storage.js          # Cookie-based persistence
│       └── dateUtils.js        # Date calculations
├── public/                     # Static assets
├── index.html                  # HTML template
├── vite.config.js              # Vite configuration
└── package.json                # Dependencies
```

## Deployment

The app is automatically deployed to GitHub Pages when changes are pushed to the main branch.

Manual deployment:
```bash
npm run deploy
```

## License

MIT
