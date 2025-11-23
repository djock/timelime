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
    background: var(--comic-white);
    padding: 2rem;
    border-radius: 0;
    border: var(--border-thick) solid var(--comic-black);
    box-shadow: var(--shadow-comic-lg);
    position: relative;
    animation: fadeInUp 0.6s ease-out 0.1s backwards;
  }

  header::before {
    content: 'POW!';
    position: absolute;
    top: -18px;
    left: 50%;
    transform: translateX(-50%) rotate(-5deg);
    font-size: 1.5rem;
    font-family: 'Bangers', cursive;
    color: var(--comic-red);
    background: var(--comic-yellow);
    padding: 0.25rem 1rem;
    border: var(--border-medium) solid var(--comic-black);
    box-shadow: var(--shadow-comic);
    letter-spacing: 2px;
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
    filter: drop-shadow(3px 3px 0px var(--comic-black));
  }

  h1 {
    font-family: 'Bangers', cursive;
    font-size: 2.5rem;
    color: var(--comic-red);
    margin: 0;
    letter-spacing: 3px;
    text-transform: uppercase;
    text-shadow:
      3px 3px 0 var(--comic-black),
      -1px -1px 0 var(--comic-white);
    font-weight: 400;
  }

  .app-description {
    font-family: 'Comic Neue', sans-serif;
    font-size: 0.95rem;
    color: var(--text-secondary);
    margin: 0.5rem 0 0 0;
    font-weight: 600;
    letter-spacing: 0.5px;
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
    background: var(--comic-gray-light);
    padding: 1.25rem 1.5rem;
    border-radius: 0;
    flex-wrap: wrap;
    gap: 1.5rem;
    border: var(--border-medium) solid var(--comic-black);
    box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
    position: relative;
  }

  .view-nav::before,
  .view-nav::after {
    content: '★';
    position: absolute;
    color: var(--comic-red);
    font-size: 1.2rem;
    top: 50%;
    transform: translateY(-50%);
  }

  .view-nav::before {
    left: 8px;
  }

  .view-nav::after {
    right: 8px;
  }

  .view-buttons {
    display: flex;
    gap: 0.75rem;
    flex: 1;
    justify-content: center;
  }

  .view-buttons button {
    background: var(--comic-white);
    color: var(--comic-black);
    border-color: var(--comic-black);
    min-width: 100px;
    box-shadow: 2px 2px 0px rgba(0, 0, 0, 0.6);
  }

  .view-buttons button:hover {
    background: var(--comic-blue);
    color: var(--comic-white);
  }

  .view-buttons button.active {
    background: var(--comic-purple);
    color: var(--comic-white);
    border-color: var(--comic-black);
    box-shadow: var(--shadow-comic);
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
    background: var(--comic-purple) !important;
    color: var(--comic-white) !important;
  }

  .primary-action:hover {
    background: #AB47BC !important;
  }

  .nav-arrow {
    background: var(--comic-purple) !important;
    color: var(--comic-white) !important;
  }

  .nav-arrow:hover {
    background: #AB47BC !important;
  }

  .time-label {
    min-width: 240px;
    text-align: center;
    font-weight: 400;
    font-size: 1.2rem;
    font-family: 'Bebas Neue', sans-serif;
    color: var(--comic-black);
    letter-spacing: 2px;
    text-transform: uppercase;
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

    .view-nav::before,
    .view-nav::after {
      display: none;
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
