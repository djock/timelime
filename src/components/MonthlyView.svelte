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
    background: linear-gradient(to bottom,
      rgba(244, 232, 208, 0.6),
      rgba(232, 220, 196, 0.4)
    );
    border-radius: 8px;
    padding: 1.75rem;
    border: 3px solid var(--border-ornate);
    box-shadow:
      0 0 0 1px var(--leather-dark),
      0 6px 20px var(--shadow-medium),
      inset 0 1px 0 rgba(255, 255, 255, 0.3);
  }

  .calendar-header {
    text-align: center;
    margin-bottom: 2rem;
    position: relative;
  }

  .calendar-header h2 {
    font-size: 1.85rem;
    font-family: 'Cinzel', serif;
    color: var(--text-gold);
    font-weight: 700;
    letter-spacing: 1px;
    text-transform: uppercase;
    text-shadow: 0 2px 4px var(--shadow-light);
  }

  .calendar-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 0.75rem;
  }

  .day-header {
    text-align: center;
    font-weight: 700;
    font-size: 0.9rem;
    padding: 0.75rem;
    color: var(--text-gold);
    font-family: 'Cinzel', serif;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    background: linear-gradient(to bottom,
      rgba(212, 175, 55, 0.2),
      transparent
    );
    border-radius: 6px;
  }

  .calendar-day {
    min-height: 110px;
    background: linear-gradient(to bottom,
      rgba(255, 254, 248, 0.9),
      rgba(244, 232, 208, 0.7)
    );
    border: 2px solid var(--border-ornate);
    border-radius: 6px;
    padding: 0.625rem;
    position: relative;
    box-shadow:
      0 2px 6px var(--shadow-light),
      inset 0 1px 0 rgba(255, 255, 255, 0.5);
    transition: all 0.3s ease;
  }

  .calendar-day:hover {
    transform: translateY(-2px);
    box-shadow:
      0 4px 12px var(--shadow-medium),
      inset 0 1px 0 rgba(255, 255, 255, 0.5);
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
    border: 3px solid var(--gold-accent);
    box-shadow:
      0 0 20px var(--glow-gold),
      0 6px 16px var(--shadow-medium),
      inset 0 1px 0 rgba(255, 255, 255, 0.6);
  }

  .day-number {
    font-weight: 900;
    font-size: 1.1rem;
    margin-bottom: 0.375rem;
    font-family: 'Cinzel', serif;
    color: var(--crimson-primary);
  }

  .day-events {
    display: flex;
    flex-direction: column;
    gap: 0.375rem;
  }

  .event-indicator {
    font-size: 0.75rem;
    padding: 0.375rem 0.625rem;
    border-radius: 4px;
    text-align: left;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    cursor: pointer;
    border: 2px solid rgba(0, 0, 0, 0.2);
    color: white;
    font-weight: 700;
    font-family: 'Cinzel', serif;
    letter-spacing: 0.3px;
    text-transform: uppercase;
    transition: all 0.3s ease;
    box-shadow:
      0 2px 4px var(--shadow-medium),
      inset 0 1px 0 rgba(255, 255, 255, 0.3);
  }

  .event-indicator:hover {
    transform: translateY(-2px);
    box-shadow:
      0 4px 8px var(--shadow-medium),
      0 0 10px var(--glow-gold);
    border-color: var(--gold-accent);
  }

  @media (max-width: 768px) {
    .monthly-view {
      padding: 1.25rem;
    }

    .calendar-grid {
      gap: 0.5rem;
    }

    .calendar-day {
      min-height: 85px;
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
