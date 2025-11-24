<script>
  import { onMount } from 'svelte';
  import EventModal from './components/EventModal.svelte';
  import EventPopup from './components/EventPopup.svelte';
  import GanttView from './components/GanttView.svelte';
  import MonthlyView from './components/MonthlyView.svelte';
  import WeeklyView from './components/WeeklyView.svelte';
  import { saveEvents, loadEvents, saveCheckIns, loadCheckIns, exportData, importData } from './lib/storage.js';
  import { getWeeksInYear, getWeekNumber } from './lib/dateUtils.js';

  let events = [];
  let checkIns = {};
  let currentView = 'gantt'; // gantt, monthly, weekly
  let selectedYear = new Date().getFullYear();
  let selectedMonth = new Date().getMonth();
  let selectedWeek = getWeekNumber(new Date());

  let showEventModal = false;
  let showEventPopup = false;
  let editingEvent = null;
  let selectedEvent = null;

  onMount(() => {
    events = loadEvents();
    checkIns = loadCheckIns();
  });

  function handleAddEvent() {
    editingEvent = null;
    showEventModal = true;
  }

  function handleSaveEvent(eventData) {
    if (editingEvent) {
      events = events.map(e => e.id === eventData.id ? eventData : e);
    } else {
      events = [...events, eventData];
    }
    saveEvents(events);
    showEventModal = false;
    editingEvent = null;
  }

  function handleEditEvent(event) {
    editingEvent = event;
    showEventPopup = false;
    showEventModal = true;
  }

  function handleDeleteEvent(eventId) {
    if (confirm('Are you sure you want to delete this event?')) {
      events = events.filter(e => e.id !== eventId);
      // Clean up check-ins for this event
      delete checkIns[eventId];
      saveEvents(events);
      saveCheckIns(checkIns);
      showEventPopup = false;
    }
  }

  function handleEventClick(event) {
    selectedEvent = event;
    showEventPopup = true;
  }

  function handleCheckIn(eventId, periodKey) {
    if (!checkIns[eventId]) {
      checkIns[eventId] = {};
    }
    checkIns[eventId][periodKey] = true;
    checkIns = { ...checkIns };
    saveCheckIns(checkIns);
  }

  function handleExport() {
    exportData();
  }

  async function handleImport(event) {
    const file = event.target.files[0];
    if (!file) return;

    try {
      const data = await importData(file);
      events = loadEvents();
      checkIns = loadCheckIns();
      alert('Data imported successfully!');
    } catch (error) {
      alert('Failed to import data: ' + error.message);
    }

    // Reset file input
    event.target.value = '';
  }

  function changeYear(delta) {
    selectedYear += delta;
  }

  function changeMonth(delta) {
    selectedMonth += delta;
    if (selectedMonth > 11) {
      selectedMonth = 0;
      selectedYear++;
    } else if (selectedMonth < 0) {
      selectedMonth = 11;
      selectedYear--;
    }
  }

  function changeWeek(delta) {
    selectedWeek += delta;
    const weeksInYear = getWeeksInYear(selectedYear);
    if (selectedWeek > weeksInYear) {
      selectedWeek = 1;
      selectedYear++;
    } else if (selectedWeek < 1) {
      selectedYear--;
      selectedWeek = getWeeksInYear(selectedYear);
    }
  }

  $: maxWeeks = getWeeksInYear(selectedYear);
</script>

<main>
  <header>
    <div class="header-content">
      <div class="logo">
        <img src="/timelime/lime-favicon.svg" alt="TimeLime" class="logo-img" />
        <div>
          <h1>TimeLime</h1>
          <p class="app-description">Track your habits and events with daily check-ins</p>
        </div>
      </div>
      <div class="header-actions">
        <input
          type="file"
          accept="application/json"
          on:change={handleImport}
          id="import-input"
          style="display: none;"
        />
        <button class="secondary" on:click={() => document.getElementById('import-input').click()}>
          Import
        </button>
        <button class="secondary" on:click={handleExport}>
          Export
        </button>
        <button class="primary-action" on:click={handleAddEvent}>
          + New Event
        </button>
      </div>
    </div>

    <nav class="view-nav">
      <div class="view-buttons">
        <button
          class:active={currentView === 'gantt'}
          on:click={() => currentView = 'gantt'}
        >
          Yearly
        </button>
        <button
          class:active={currentView === 'monthly'}
          on:click={() => currentView = 'monthly'}
        >
          Monthly
        </button>
        <button
          class:active={currentView === 'weekly'}
          on:click={() => currentView = 'weekly'}
        >
          Weekly
        </button>
      </div>

      <div class="time-navigation">
        {#if currentView === 'gantt'}
          <button class="nav-arrow" on:click={() => changeYear(-1)}>←</button>
          <span class="time-label">{selectedYear}</span>
          <button class="nav-arrow" on:click={() => changeYear(1)}>→</button>
        {:else if currentView === 'monthly'}
          <button class="nav-arrow" on:click={() => changeMonth(-1)}>←</button>
          <span class="time-label">
            {new Date(selectedYear, selectedMonth).toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}
          </span>
          <button class="nav-arrow" on:click={() => changeMonth(1)}>→</button>
        {:else if currentView === 'weekly'}
          <button class="nav-arrow" on:click={() => changeWeek(-1)}>←</button>
          <span class="time-label">Week {selectedWeek}, {selectedYear}</span>
          <button class="nav-arrow" on:click={() => changeWeek(1)}>→</button>
        {/if}
      </div>
    </nav>
  </header>

  <div class="content">
    {#if currentView === 'gantt'}
      <GanttView
        {events}
        {selectedYear}
        onEventClick={handleEventClick}
      />
    {:else if currentView === 'monthly'}
      <MonthlyView
        {events}
        {selectedYear}
        {selectedMonth}
        onEventClick={handleEventClick}
      />
    {:else if currentView === 'weekly'}
      <WeeklyView
        {events}
        {selectedYear}
        {selectedWeek}
        onEventClick={handleEventClick}
      />
    {/if}
  </div>

  {#if showEventModal}
    <EventModal
      event={editingEvent}
      onSave={handleSaveEvent}
      onClose={() => {
        showEventModal = false;
        editingEvent = null;
      }}
    />
  {/if}

  {#if showEventPopup && selectedEvent}
    <EventPopup
      event={selectedEvent}
      {checkIns}
      onCheckIn={handleCheckIn}
      onEdit={handleEditEvent}
      onDelete={handleDeleteEvent}
      onClose={() => {
        showEventPopup = false;
        selectedEvent = null;
      }}
    />
  {/if}
</main>

<style>
  main {
    max-width: 1500px;
    margin: 0 auto;
    animation: fadeInUp 0.6s ease-out;
  }

  header {
    margin-bottom: 2rem;
    background: var(--cream-light);
    padding: 2rem;
    border-radius: 20px;
    box-shadow: var(--shadow-lifted);
    position: relative;
    animation: fadeInUp 0.6s ease-out 0.1s backwards;
    border: 2px solid var(--sage-green);
  }

  .header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    flex-wrap: wrap;
    gap: 1.5rem;
  }

  .logo {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .logo-img {
    width: 48px;
    height: 48px;
    filter: drop-shadow(0 2px 4px rgba(45, 62, 47, 0.2));
  }

  h1 {
    font-family: 'Merriweather', serif;
    font-size: 2.2rem;
    color: var(--forest-green);
    margin: 0;
    letter-spacing: 0.5px;
    font-weight: 700;
  }

  .app-description {
    font-family: 'Nunito', sans-serif;
    font-size: 0.95rem;
    color: var(--text-secondary);
    margin: 0.5rem 0 0 0;
    font-weight: 400;
    letter-spacing: 0.3px;
  }

  .header-actions {
    display: flex;
    gap: 0.75rem;
    flex-wrap: wrap;
  }

  .view-nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: var(--cream);
    padding: 1.25rem 1.5rem;
    border-radius: 20px;
    flex-wrap: wrap;
    gap: 1.5rem;
    box-shadow: var(--shadow-card);
    position: relative;
    border: 2px solid var(--sage-green);
  }

  .view-buttons {
    display: flex;
    gap: 0.75rem;
    flex: 1;
    justify-content: center;
  }

  .view-buttons button {
    background: var(--cream-light);
    color: var(--text-primary);
    min-width: 100px;
    border: 2px solid var(--sage-green);
  }

  .view-buttons button:hover {
    background: var(--sage-green);
    color: var(--forest-green);
  }

  .view-buttons button.active {
    background: var(--moss-green);
    color: var(--text-light);
    border-color: var(--moss-green-dark);
  }

  .time-navigation {
    display: flex;
    align-items: center;
    gap: 1.25rem;
  }

  .time-navigation button {
    min-width: 50px;
    padding: 0.625rem 1rem;
  }

  .primary-action {
    background: var(--terracotta) !important;
    color: var(--text-light) !important;
  }

  .primary-action:hover {
    background: var(--terracotta-dark) !important;
  }

  .nav-arrow {
    background: var(--slate-blue) !important;
    color: var(--text-light) !important;
  }

  .nav-arrow:hover {
    background: var(--slate-blue-dark) !important;
  }

  .time-label {
    min-width: 240px;
    text-align: center;
    font-weight: 600;
    font-size: 1.1rem;
    font-family: 'Merriweather', serif;
    color: var(--forest-green);
    letter-spacing: 0.5px;
  }

  .content {
    min-height: 500px;
    animation: fadeInUp 0.6s ease-out 0.2s backwards;
  }

  @media (max-width: 768px) {
    header {
      padding: 1.5rem 1rem;
    }

    .header-content {
      flex-direction: column;
      align-items: stretch;
    }

    .header-actions {
      justify-content: stretch;
    }

    .header-actions button {
      flex: 1;
    }

    .view-nav {
      flex-direction: column;
      padding: 1rem;
    }

    .view-buttons {
      width: 100%;
    }

    .view-buttons button {
      flex: 1;
      min-width: auto;
    }

    .time-label {
      min-width: auto;
      font-size: 1rem;
    }

    h1 {
      font-size: 1.75rem;
    }

    .app-description {
      font-size: 0.85rem;
    }
  }
</style>
