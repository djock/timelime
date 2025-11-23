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
    background: var(--comic-white);
    border-radius: 0;
    padding: 1.75rem;
    border: var(--border-thick) solid var(--comic-black);
    box-shadow: var(--shadow-comic-lg);
    background-image:
      radial-gradient(circle, rgba(0, 102, 204, 0.03) 1px, transparent 1px);
    background-size: 12px 12px;
    max-width: 100%;
    overflow: hidden;
  }

  .calendar-header {
    text-align: center;
    margin-bottom: 2rem;
    position: relative;
  }

  .calendar-header h2 {
    font-size: 1.85rem;
    font-family: 'Bangers', cursive;
    color: var(--comic-red);
    font-weight: 400;
    letter-spacing: 2px;
    text-transform: uppercase;
    text-shadow:
      2px 2px 0 var(--comic-black),
      -1px -1px 0 var(--comic-white);
  }

  .calendar-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 0.75rem;
    width: 100%;
  }

  .day-header {
    text-align: center;
    font-weight: 400;
    font-size: 0.9rem;
    padding: 0.75rem;
    color: var(--comic-black);
    font-family: 'Bebas Neue', sans-serif;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    background: var(--comic-yellow);
    border-radius: 0;
    border: 2px solid var(--comic-black);
  }

  .calendar-day {
    aspect-ratio: 1 / 1;
    background: var(--comic-white);
    border: var(--border-thin) solid var(--comic-black);
    border-radius: 0;
    padding: 0.625rem;
    position: relative;
    box-shadow: 1px 1px 0px rgba(0, 0, 0, 0.3);
    transition: all 0.2s ease;
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  .calendar-day:hover {
    transform: translate(-1px, -1px);
    box-shadow: 2px 2px 0px rgba(0, 0, 0, 0.5);
  }

  .calendar-day.empty {
    background: transparent;
    border: none;
    box-shadow: none;
  }

  .calendar-day.empty:hover {
    transform: none;
  }

  .calendar-day.today {
    border: var(--border-medium) solid var(--comic-red);
    box-shadow: 3px 3px 0px var(--comic-yellow);
  }

  .day-number {
    font-weight: 400;
    font-size: 1.1rem;
    margin-bottom: 0.375rem;
    font-family: 'Bebas Neue', sans-serif;
    color: var(--comic-black);
  }

  .day-events {
    display: flex;
    flex-direction: column;
    gap: 0.375rem;
    flex: 1;
    overflow-y: auto;
    min-height: 0;
  }

  .event-indicator {
    font-size: 0.7rem;
    padding: 0.375rem 0.625rem;
    border-radius: 0;
    text-align: left;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    cursor: pointer;
    border: 2px solid var(--comic-black);
    color: white;
    font-weight: 400;
    font-family: 'Bebas Neue', sans-serif;
    letter-spacing: 1px;
    text-transform: uppercase;
    transition: all 0.2s ease;
    box-shadow: 2px 2px 0px rgba(0, 0, 0, 0.5);
  }

  .event-indicator:hover {
    transform: translate(-1px, -1px);
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.7);
  }

  @media (max-width: 768px) {
    .monthly-view {
      padding: 1.25rem;
    }

    .calendar-grid {
      gap: 0.5rem;
    }

    .calendar-day {
      padding: 0.5rem;
    }

    .event-indicator {
      font-size: 0.65rem;
      padding: 0.25rem 0.4rem;
    }

    .calendar-header h2 {
      font-size: 1.4rem;
    }
  }
</style>
