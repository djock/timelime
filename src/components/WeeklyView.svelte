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

  .week-header {
    text-align: center;
    margin-bottom: 2rem;
    position: relative;
  }

  .week-header h2 {
    font-size: 1.75rem;
    font-family: 'Cinzel', serif;
    color: var(--text-gold);
    font-weight: 700;
    letter-spacing: 1px;
    text-transform: uppercase;
    text-shadow: 0 2px 4px var(--shadow-light);
  }

  .week-range {
    font-size: 1rem;
    color: var(--text-secondary);
    margin-top: 0.5rem;
    font-family: 'Crimson Pro', serif;
    font-weight: 600;
  }

  .week-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 0.875rem;
  }

  .week-day {
    background: linear-gradient(to bottom,
      rgba(255, 254, 248, 0.9),
      rgba(244, 232, 208, 0.7)
    );
    border: 2px solid var(--border-ornate);
    border-radius: 8px;
    min-height: 320px;
    display: flex;
    flex-direction: column;
    box-shadow:
      0 4px 12px var(--shadow-light),
      inset 0 1px 0 rgba(255, 255, 255, 0.5);
    transition: all 0.3s ease;
  }

  .week-day:hover {
    transform: translateY(-2px);
    box-shadow:
      0 6px 16px var(--shadow-medium),
      inset 0 1px 0 rgba(255, 255, 255, 0.5);
  }

  .week-day.today {
    border: 3px solid var(--gold-accent);
    box-shadow:
      0 0 20px var(--glow-gold),
      0 6px 16px var(--shadow-medium),
      inset 0 1px 0 rgba(255, 255, 255, 0.5);
  }

  .day-header {
    padding: 1.25rem;
    text-align: center;
    border-bottom: 2px solid var(--border-ornate);
    background: linear-gradient(to bottom,
      rgba(212, 175, 55, 0.15),
      transparent
    );
  }

  .day-name {
    font-weight: 700;
    font-size: 0.9rem;
    color: var(--text-gold);
    font-family: 'Cinzel', serif;
    letter-spacing: 0.5px;
    text-transform: uppercase;
  }

  .day-date {
    font-size: 1.75rem;
    font-weight: 900;
    margin-top: 0.375rem;
    font-family: 'Cinzel', serif;
    color: var(--crimson-primary);
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
    background: linear-gradient(145deg, var(--parchment-light), #FFFEF8);
    border-radius: 6px;
    padding: 0.875rem;
    cursor: pointer;
    transition: all 0.3s ease;
    text-align: left;
    border: 2px solid var(--border-ornate);
    color: var(--text-primary);
    box-shadow:
      0 2px 6px var(--shadow-light),
      inset 0 1px 0 rgba(255, 255, 255, 0.5);
  }

  .event-card:hover {
    transform: translateY(-3px);
    box-shadow:
      0 6px 12px var(--shadow-medium),
      0 0 15px var(--glow-gold);
    border-color: var(--gold-accent);
  }

  .event-title {
    font-weight: 700;
    font-size: 0.95rem;
    margin-bottom: 0.375rem;
    font-family: 'Crimson Pro', serif;
    color: var(--text-primary);
  }

  .event-time {
    font-size: 0.75rem;
    color: var(--text-secondary);
    font-family: 'Crimson Pro', serif;
  }

  @media (max-width: 1200px) {
    .week-grid {
      grid-template-columns: repeat(4, 1fr);
    }
  }

  @media (max-width: 768px) {
    .weekly-view {
      padding: 1.25rem;
    }

    .week-grid {
      grid-template-columns: repeat(2, 1fr);
    }

    .week-day {
      min-height: 220px;
    }

    .week-header h2 {
      font-size: 1.35rem;
    }
  }
</style>
