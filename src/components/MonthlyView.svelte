<script>
  export let events = [];
  export let selectedYear = new Date().getFullYear();
  export let selectedMonth = new Date().getMonth();
  export let onEventClick;

  const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  function getDaysInMonth(year, month) {
    return new Date(year, month + 1, 0).getDate();
  }

  function getFirstDayOfMonth(year, month) {
    return new Date(year, month, 1).getDay();
  }

  function generateCalendarDays(year, month) {
    const daysInMonth = getDaysInMonth(year, month);
    const firstDay = getFirstDayOfMonth(year, month);
    const days = [];

    // Add empty cells for days before month starts
    for (let i = 0; i < firstDay; i++) {
      days.push(null);
    }

    // Add days of month
    for (let day = 1; day <= daysInMonth; day++) {
      days.push(day);
    }

    return days;
  }

  function getEventsForDay(day) {
    if (!day) return [];

    const date = new Date(selectedYear, selectedMonth, day);
    const dateStr = date.toISOString().split('T')[0];

    return events.filter(event => {
      const start = new Date(event.startDate);
      const end = new Date(event.endDate);
      return date >= start && date <= end;
    });
  }

  function isToday(day) {
    if (!day) return false;
    const today = new Date();
    return today.getFullYear() === selectedYear &&
           today.getMonth() === selectedMonth &&
           today.getDate() === day;
  }

  $: calendarDays = generateCalendarDays(selectedYear, selectedMonth);
</script>

<div class="monthly-view">
  <div class="calendar-header">
    <h2>{monthNames[selectedMonth]} {selectedYear}</h2>
  </div>

  <div class="calendar-grid">
    {#each daysOfWeek as day}
      <div class="day-header">{day}</div>
    {/each}

    {#each calendarDays as day}
      <div class="calendar-day" class:empty={!day} class:today={isToday(day)}>
        {#if day}
          <div class="day-number">{day}</div>
          <div class="day-events">
            {#each getEventsForDay(day) as event}
              <button
                class="event-indicator"
                style="background-color: {event.color};"
                on:click={() => onEventClick(event)}
                title={event.title}
              >
                {event.title}
              </button>
            {/each}
          </div>
        {/if}
      </div>
    {/each}
  </div>
</div>

<style>
  .monthly-view {
    background-color: var(--bg-secondary);
    border-radius: 0.5rem;
    padding: 1rem;
  }

  .calendar-header {
    text-align: center;
    margin-bottom: 1.5rem;
  }

  .calendar-header h2 {
    font-size: 1.5rem;
    color: var(--lime-dark);
  }

  .calendar-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 0.5rem;
  }

  .day-header {
    text-align: center;
    font-weight: 600;
    font-size: 0.875rem;
    padding: 0.5rem;
    color: var(--text-secondary);
  }

  .calendar-day {
    min-height: 100px;
    background-color: var(--bg-tertiary);
    border-radius: 0.375rem;
    padding: 0.5rem;
    position: relative;
  }

  .calendar-day.empty {
    background-color: transparent;
  }

  .calendar-day.today {
    border: 2px solid var(--lime-dark);
  }

  .day-number {
    font-weight: 600;
    font-size: 0.875rem;
    margin-bottom: 0.25rem;
  }

  .day-events {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }

  .event-indicator {
    font-size: 0.75rem;
    padding: 0.25rem 0.5rem;
    border-radius: 0.25rem;
    text-align: left;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    cursor: pointer;
    border: none;
    color: white;
    font-weight: 500;
    transition: opacity 0.2s;
  }

  .event-indicator:hover {
    opacity: 0.8;
  }

  @media (max-width: 768px) {
    .calendar-day {
      min-height: 80px;
    }

    .event-indicator {
      font-size: 0.625rem;
      padding: 0.125rem 0.25rem;
    }
  }
</style>
