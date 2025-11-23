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
    background: var(--comic-white);
    border-radius: 0;
    padding: 1.75rem;
    border: var(--border-thick) solid var(--comic-black);
    box-shadow: var(--shadow-comic-lg);
    background-image:
      radial-gradient(circle, rgba(237, 28, 36, 0.03) 1px, transparent 1px);
    background-size: 12px 12px;
    max-width: 100%;
    overflow: hidden;
  }

  .week-header {
    text-align: center;
    margin-bottom: 2rem;
    position: relative;
  }

  .week-header h2 {
    font-size: 1.75rem;
    font-family: 'Bangers', cursive;
    color: var(--comic-blue);
    font-weight: 400;
    letter-spacing: 2px;
    text-transform: uppercase;
    text-shadow:
      2px 2px 0 var(--comic-black),
      -1px -1px 0 var(--comic-white);
  }

  .week-range {
    font-size: 1rem;
    color: var(--text-secondary);
    margin-top: 0.5rem;
    font-family: 'Comic Neue', sans-serif;
    font-weight: 700;
  }

  .week-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    grid-auto-rows: minmax(150px, auto);
    gap: 0.875rem;
    width: 100%;
  }

  .week-day {
    background: var(--comic-white);
    border: var(--border-medium) solid var(--comic-black);
    border-radius: 0;
    min-height: 150px;
    display: flex;
    flex-direction: column;
    box-shadow: 2px 2px 0px rgba(0, 0, 0, 0.4);
    transition: all 0.2s ease;
    height: 100%;
  }

  .week-day:hover {
    transform: translate(-2px, -2px);
    box-shadow: 4px 4px 0px rgba(0, 0, 0, 0.6);
  }

  .week-day.today {
    border: var(--border-thick) solid var(--comic-red);
    box-shadow: 4px 4px 0px var(--comic-yellow);
  }

  .day-header {
    padding: 1.25rem;
    text-align: center;
    border-bottom: var(--border-medium) solid var(--comic-black);
    background: var(--comic-yellow);
  }

  .day-name {
    font-weight: 400;
    font-size: 0.9rem;
    color: var(--comic-black);
    font-family: 'Bebas Neue', sans-serif;
    letter-spacing: 1.5px;
    text-transform: uppercase;
  }

  .day-date {
    font-size: 1.75rem;
    font-weight: 400;
    margin-top: 0.375rem;
    font-family: 'Bangers', cursive;
    color: var(--comic-red);
    text-shadow: 2px 2px 0px var(--comic-black);
  }

  .day-events {
    padding: 0.75rem;
    display: flex;
    flex-direction: column;
    gap: 0.625rem;
    overflow-y: auto;
    flex: 1;
  }

  .event-card {
    background: var(--comic-gray-light);
    border-radius: 0;
    padding: 0.875rem;
    cursor: pointer;
    transition: all 0.2s ease;
    text-align: left;
    border: var(--border-thin) solid var(--comic-black);
    color: var(--text-primary);
    box-shadow: 2px 2px 0px rgba(0, 0, 0, 0.3);
  }

  .event-card:hover {
    transform: translate(-1px, -1px);
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.5);
  }

  .event-title {
    font-weight: 700;
    font-size: 0.95rem;
    margin-bottom: 0.375rem;
    font-family: 'Comic Neue', sans-serif;
    color: var(--text-primary);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .event-time {
    font-size: 0.7rem;
    color: var(--text-secondary);
    font-family: 'Comic Neue', sans-serif;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  @media (max-width: 1200px) {
    .week-grid {
      grid-template-columns: repeat(4, 1fr);
      grid-auto-rows: minmax(150px, auto);
    }
  }

  @media (max-width: 768px) {
    .weekly-view {
      padding: 1.25rem;
    }

    .week-grid {
      grid-template-columns: repeat(2, 1fr);
      grid-auto-rows: minmax(120px, auto);
    }

    .week-day {
      min-height: 120px;
    }

    .week-header h2 {
      font-size: 1.35rem;
    }
  }
</style>
