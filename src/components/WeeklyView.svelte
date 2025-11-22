<script>
  export let events = [];
  export let selectedYear = new Date().getFullYear();
  export let selectedWeek = 1;
  export let onEventClick;

  const daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  function getWeekDates(year, week) {
    // ISO week date calculation
    const jan4 = new Date(year, 0, 4);
    const jan4Day = jan4.getDay() || 7;
    const firstMonday = new Date(jan4);
    firstMonday.setDate(jan4.getDate() - jan4Day + 1);

    const weekStart = new Date(firstMonday);
    weekStart.setDate(firstMonday.getDate() + (week - 1) * 7);

    const dates = [];
    for (let i = 0; i < 7; i++) {
      const date = new Date(weekStart);
      date.setDate(weekStart.getDate() + i);
      dates.push(date);
    }

    return dates;
  }

  function getEventsForDay(date) {
    const dateStr = date.toISOString().split('T')[0];
    return events.filter(event => {
      const start = new Date(event.startDate);
      const end = new Date(event.endDate);
      return date >= start && date <= end;
    });
  }

  function isToday(date) {
    const today = new Date();
    return today.toISOString().split('T')[0] === date.toISOString().split('T')[0];
  }

  $: weekDates = getWeekDates(selectedYear, selectedWeek);
  $: weekRange = weekDates.length > 0 ?
    `${weekDates[0].toLocaleDateString()} - ${weekDates[6].toLocaleDateString()}` : '';
</script>

<div class="weekly-view">
  <div class="week-header">
    <h2>Week {selectedWeek}, {selectedYear}</h2>
    <p class="week-range">{weekRange}</p>
  </div>

  <div class="week-grid">
    {#each weekDates as date, i}
      <div class="week-day" class:today={isToday(date)}>
        <div class="day-header">
          <div class="day-name">{daysOfWeek[date.getDay()]}</div>
          <div class="day-date">{date.getDate()}</div>
        </div>
        <div class="day-events">
          {#each getEventsForDay(date) as event}
            <button
              class="event-card"
              style="border-left: 4px solid {event.color};"
              on:click={() => onEventClick(event)}
            >
              <div class="event-title">{event.title}</div>
              <div class="event-time">
                {new Date(event.startDate).toLocaleDateString()} - {new Date(event.endDate).toLocaleDateString()}
              </div>
            </button>
          {/each}
        </div>
      </div>
    {/each}
  </div>
</div>

<style>
  .weekly-view {
    background-color: var(--bg-secondary);
    border-radius: 0.5rem;
    padding: 1rem;
  }

  .week-header {
    text-align: center;
    margin-bottom: 1.5rem;
  }

  .week-header h2 {
    font-size: 1.5rem;
    color: var(--lime-dark);
  }

  .week-range {
    font-size: 0.875rem;
    color: var(--text-secondary);
    margin-top: 0.25rem;
  }

  .week-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 0.5rem;
  }

  .week-day {
    background-color: var(--bg-tertiary);
    border-radius: 0.375rem;
    min-height: 300px;
    display: flex;
    flex-direction: column;
  }

  .week-day.today {
    border: 2px solid var(--lime-dark);
  }

  .day-header {
    padding: 1rem;
    text-align: center;
    border-bottom: 1px solid var(--border-color);
  }

  .day-name {
    font-weight: 600;
    font-size: 0.875rem;
    color: var(--text-secondary);
  }

  .day-date {
    font-size: 1.5rem;
    font-weight: bold;
    margin-top: 0.25rem;
  }

  .day-events {
    padding: 0.5rem;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    overflow-y: auto;
  }

  .event-card {
    background-color: var(--bg-secondary);
    border-radius: 0.25rem;
    padding: 0.75rem;
    cursor: pointer;
    transition: transform 0.2s, box-shadow 0.2s;
    text-align: left;
    border: none;
    color: var(--text-primary);
  }

  .event-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
  }

  .event-title {
    font-weight: 600;
    font-size: 0.875rem;
    margin-bottom: 0.25rem;
  }

  .event-time {
    font-size: 0.75rem;
    color: var(--text-secondary);
  }

  @media (max-width: 1200px) {
    .week-grid {
      grid-template-columns: repeat(4, 1fr);
    }
  }

  @media (max-width: 768px) {
    .week-grid {
      grid-template-columns: repeat(2, 1fr);
    }

    .week-day {
      min-height: 200px;
    }
  }
</style>
