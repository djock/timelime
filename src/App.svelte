<script>
  import { onMount } from 'svelte';
  import EventModal from './components/EventModal.svelte';
  import EventPopup from './components/EventPopup.svelte';
  import GanttView from './components/GanttView.svelte';
  import MonthlyView from './components/MonthlyView.svelte';
  import WeeklyView from './components/WeeklyView.svelte';
  import { saveEvents, loadEvents, saveCheckIns, loadCheckIns, exportData, importData } from './lib/storage.js';
  import { getWeeksInYear } from './lib/dateUtils.js';

  let events = [];
  let checkIns = {};
  let currentView = 'gantt'; // gantt, monthly, weekly
  let selectedYear = new Date().getFullYear();
  let selectedMonth = new Date().getMonth();
  let selectedWeek = Math.ceil((new Date().getDate() + new Date(selectedYear, 0, 1).getDay()) / 7);

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
        <h1>TimeLime</h1>
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
        <button on:click={handleAddEvent}>
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
          <button on:click={() => changeYear(-1)}>←</button>
          <span class="time-label">{selectedYear}</span>
          <button on:click={() => changeYear(1)}>→</button>
        {:else if currentView === 'monthly'}
          <button on:click={() => changeMonth(-1)}>←</button>
          <span class="time-label">
            {new Date(selectedYear, selectedMonth).toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}
          </span>
          <button on:click={() => changeMonth(1)}>→</button>
        {:else if currentView === 'weekly'}
          <button on:click={() => changeWeek(-1)}>←</button>
          <span class="time-label">Week {selectedWeek}, {selectedYear}</span>
          <button on:click={() => changeWeek(1)}>→</button>
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
    animation: fadeInUp 0.8s ease-out;
  }

  header {
    margin-bottom: 2.5rem;
    background: linear-gradient(to bottom,
      rgba(212, 175, 55, 0.12),
      transparent
    );
    padding: 2rem;
    border-radius: 12px;
    border: 3px solid var(--border-ornate);
    box-shadow:
      0 0 0 1px var(--leather-dark),
      0 8px 24px var(--shadow-medium),
      inset 0 1px 0 rgba(255, 255, 255, 0.2);
    position: relative;
    animation: fadeInUp 0.8s ease-out 0.2s backwards;
  }

  header::before {
    content: '⚔';
    position: absolute;
    top: -12px;
    left: 50%;
    transform: translateX(-50%);
    font-size: 2rem;
    color: var(--gold-accent);
    text-shadow: 0 0 15px var(--glow-gold);
    animation: float 3s ease-in-out infinite;
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
    filter: drop-shadow(0 4px 8px var(--shadow-medium));
    animation: float 4s ease-in-out infinite;
  }

  h1 {
    font-family: 'MedievalSharp', 'Cinzel', serif;
    font-size: 2.5rem;
    background: linear-gradient(135deg, var(--crimson-primary), var(--gold-accent), var(--crimson-dark));
    background-size: 200% 200%;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    margin: 0;
    letter-spacing: 2px;
    text-shadow: 0 2px 4px var(--shadow-light);
    animation: shimmer 8s ease infinite;
    filter: drop-shadow(0 2px 4px rgba(139, 21, 56, 0.3));
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
    background: linear-gradient(to bottom,
      rgba(212, 196, 168, 0.3),
      rgba(232, 220, 196, 0.2)
    );
    padding: 1.25rem 1.5rem;
    border-radius: 8px;
    flex-wrap: wrap;
    gap: 1.5rem;
    border: 2px solid var(--border-ornate);
    box-shadow:
      0 4px 12px var(--shadow-light),
      inset 0 1px 0 rgba(255, 255, 255, 0.3);
    position: relative;
  }

  .view-nav::before,
  .view-nav::after {
    content: '◈';
    position: absolute;
    color: var(--gold-dark);
    font-size: 1rem;
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
    background: linear-gradient(145deg, var(--parchment-dark), var(--parchment-medium));
    color: var(--text-secondary);
    border-color: var(--border-ornate);
    min-width: 100px;
  }

  .view-buttons button:hover {
    background: linear-gradient(145deg, var(--gold-dark), #8B6914);
    color: var(--text-light);
  }

  .view-buttons button.active {
    background: linear-gradient(145deg, var(--crimson-primary), var(--crimson-dark));
    color: var(--text-light);
    border-color: var(--gold-accent);
    box-shadow:
      0 0 15px var(--glow-crimson),
      0 4px 8px var(--shadow-medium),
      inset 0 1px 0 rgba(255, 255, 255, 0.2);
  }

  .time-navigation {
    display: flex;
    align-items: center;
    gap: 1.25rem;
  }

  .time-navigation button {
    min-width: 45px;
    padding: 0.625rem 1rem;
  }

  .time-label {
    min-width: 240px;
    text-align: center;
    font-weight: 700;
    font-size: 1.1rem;
    font-family: 'Cinzel', serif;
    color: var(--text-gold);
    letter-spacing: 0.5px;
    text-transform: uppercase;
  }

  .content {
    min-height: 500px;
    animation: fadeInUp 0.8s ease-out 0.4s backwards;
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
  }
</style>
