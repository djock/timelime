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
          Gantt
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
    max-width: 1400px;
    margin: 0 auto;
  }

  header {
    margin-bottom: 2rem;
  }

  .header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
    flex-wrap: wrap;
    gap: 1rem;
  }

  .logo {
    display: flex;
    align-items: center;
    gap: 0.75rem;
  }

  .logo-img {
    width: 40px;
    height: 40px;
  }

  h1 {
    font-size: 2rem;
    color: var(--lime-dark);
    margin: 0;
  }

  .header-actions {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;
  }

  .view-nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background-color: var(--bg-secondary);
    padding: 1rem;
    border-radius: 0.5rem;
    flex-wrap: wrap;
    gap: 1rem;
  }

  .view-buttons {
    display: flex;
    gap: 0.5rem;
  }

  .view-buttons button {
    background-color: var(--bg-tertiary);
  }

  .view-buttons button.active {
    background-color: var(--lime-dark);
  }

  .time-navigation {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .time-label {
    min-width: 200px;
    text-align: center;
    font-weight: 600;
    font-size: 1rem;
  }

  .content {
    min-height: 500px;
  }

  @media (max-width: 768px) {
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
    }

    .view-buttons {
      width: 100%;
    }

    .view-buttons button {
      flex: 1;
    }

    .time-label {
      min-width: auto;
    }

    h1 {
      font-size: 1.5rem;
    }
  }
</style>
