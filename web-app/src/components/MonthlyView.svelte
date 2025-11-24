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
      return dateStr >= event.startDate && dateStr <= event.endDate;
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
    font-family: 'Merriweather', serif;
    color: var(--forest-green);
    font-weight: 700;
    letter-spacing: 0.5px;
  }

  .calendar-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 0.75rem;
    width: 100%;
  }

  .day-header {
    text-align: center;
    font-weight: 600;
    font-size: 0.85rem;
    padding: 0.75rem;
    color: var(--forest-green);
    font-family: 'Nunito', sans-serif;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    background: var(--moss-green-light);
    border-radius: 10px;
    border: 2px solid var(--sage-green);
  }

  .calendar-day {
    aspect-ratio: 1 / 1;
    background: var(--cream-light);
    border: 2px solid var(--sage-green);
    border-radius: 12px;
    padding: 0.625rem;
    position: relative;
    box-shadow: var(--shadow-card);
    transition: all 0.3s ease;
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  .calendar-day:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-soft);
    border-color: var(--moss-green);
  }

  .calendar-day.empty {
    background: transparent;
    border: 2px solid transparent;
    box-shadow: none;
  }

  .calendar-day.empty:hover {
    transform: none;
  }

  .calendar-day.today {
    border: 3px solid var(--terracotta);
    box-shadow: 0 0 0 3px var(--terracotta-light);
  }

  .day-number {
    font-weight: 700;
    font-size: 1.1rem;
    margin-bottom: 0.375rem;
    font-family: 'Merriweather', serif;
    color: var(--forest-green);
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
    border-radius: 8px;
    text-align: left;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    cursor: pointer;
    border: 2px solid rgba(0, 0, 0, 0.1);
    color: white;
    font-weight: 600;
    font-family: 'Nunito', sans-serif;
    letter-spacing: 0.3px;
    transition: all 0.3s ease;
    box-shadow: var(--shadow-card);
  }

  .event-indicator:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-soft);
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
