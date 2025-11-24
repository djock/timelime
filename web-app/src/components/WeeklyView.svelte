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
      return dateStr >= event.startDate && dateStr <= event.endDate;
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
    overflow-x: hidden;
  }

  .week-header {
    text-align: center;
    margin-bottom: 2rem;
    position: relative;
  }

  .week-header h2 {
    font-size: 1.75rem;
    font-family: 'Merriweather', serif;
    color: var(--forest-green);
    font-weight: 700;
    letter-spacing: 0.5px;
  }

  .week-range {
    font-size: 1rem;
    color: var(--text-secondary);
    margin-top: 0.5rem;
    font-family: 'Nunito', sans-serif;
    font-weight: 600;
  }

  .week-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    grid-auto-rows: minmax(150px, auto);
    gap: 0.875rem;
    width: 100%;
  }

  .week-day {
    background: var(--cream-light);
    border: 2px solid var(--sage-green);
    border-radius: 16px;
    display: flex;
    flex-direction: column;
    box-shadow: var(--shadow-card);
    transition: all 0.3s ease;
    overflow: hidden;
  }

  .week-day:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-soft);
    border-color: var(--moss-green);
  }

  .week-day.today {
    border: 3px solid var(--terracotta);
    box-shadow: 0 0 0 3px var(--terracotta-light);
  }

  .day-header {
    padding: 1.25rem;
    text-align: center;
    border-bottom: 2px solid var(--sage-green);
    background: var(--moss-green-light);
  }

  .day-name {
    font-weight: 600;
    font-size: 0.9rem;
    color: var(--forest-green);
    font-family: 'Nunito', sans-serif;
    letter-spacing: 0.5px;
    text-transform: uppercase;
  }

  .day-date {
    font-size: 1.6rem;
    font-weight: 700;
    margin-top: 0.375rem;
    font-family: 'Merriweather', serif;
    color: var(--forest-green);
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
    background: var(--cream);
    border-radius: 10px;
    padding: 0.875rem;
    cursor: pointer;
    transition: all 0.3s ease;
    text-align: left;
    border: 2px solid var(--sage-green);
    color: var(--text-primary);
    box-shadow: var(--shadow-card);
  }

  .event-card:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-soft);
    border-color: var(--moss-green);
  }

  .event-title {
    font-weight: 600;
    font-size: 0.95rem;
    margin-bottom: 0.375rem;
    font-family: 'Nunito', sans-serif;
    color: var(--text-primary);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .event-time {
    font-size: 0.75rem;
    color: var(--text-secondary);
    font-family: 'Nunito', sans-serif;
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
      padding: 1rem;
    }

    .week-grid {
      grid-template-columns: repeat(2, 1fr);
      grid-auto-rows: minmax(140px, auto);
      gap: 0.625rem;
    }

    .week-header {
      margin-bottom: 1.25rem;
    }

    .week-header h2 {
      font-size: 1.35rem;
    }

    .day-header {
      padding: 0.875rem;
    }

    .day-date {
      font-size: 1.4rem;
    }

    .day-events {
      padding: 0.625rem;
    }
  }

  @media (max-width: 480px) {
    .weekly-view {
      padding: 0.75rem;
    }

    .week-grid {
      grid-template-columns: 1fr;
      grid-auto-rows: minmax(120px, auto);
      gap: 0.5rem;
    }

    .day-header {
      padding: 0.75rem;
    }

    .day-date {
      font-size: 1.25rem;
    }
  }
</style>
