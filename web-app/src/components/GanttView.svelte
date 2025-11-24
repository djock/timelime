<script>
  export let events = [];
  export let selectedYear = new Date().getFullYear();
  export let onEventClick;

  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  let visibleEvents = [];

  function getEventPosition(event) {
    const yearStart = new Date(selectedYear, 0, 1);
    const yearEnd = new Date(selectedYear, 11, 31);
    const eventStart = new Date(event.startDate);
    const eventEnd = new Date(event.endDate);

    // Clamp to current year
    const clampedStart = eventStart < yearStart ? yearStart : eventStart;
    const clampedEnd = eventEnd > yearEnd ? yearEnd : eventEnd;

    const yearLength = yearEnd - yearStart;
    const left = ((clampedStart - yearStart) / yearLength) * 100;
    const width = ((clampedEnd - clampedStart) / yearLength) * 100;

    return {
      left: `${Math.max(0, left)}%`,
      width: `${Math.max(0.5, width)}%`,
      visible: eventEnd >= yearStart && eventStart <= yearEnd
    };
  }

  // Explicitly depend on both events and selectedYear for reactivity
  $: {
    const yearStart = new Date(selectedYear, 0, 1);
    const yearEnd = new Date(selectedYear, 11, 31);
    visibleEvents = events.filter(event => {
      const eventStart = new Date(event.startDate);
      const eventEnd = new Date(event.endDate);
      return eventEnd >= yearStart && eventStart <= yearEnd;
    });
  }
</script>

<div class="gantt-container">
  <div class="gantt-header">
    <div class="gantt-timeline">
      {#each months as month, i}
        <div class="month-marker" style="left: {(i / 12) * 100}%">
          <div class="month-label">{month}</div>
        </div>
      {/each}
    </div>
  </div>

  <div class="gantt-body">
    {#if visibleEvents.length === 0}
      <div class="empty-state">
        <p>No events in {selectedYear}</p>
        <p class="empty-hint">Add an event to get started</p>
      </div>
    {:else}
      {#each visibleEvents as event}
        {@const position = getEventPosition(event)}
        <div class="gantt-row">
          <div class="event-timeline">
            <button
              class="event-bar"
              style="left: {position.left}; width: {position.width}; background-color: {event.color};"
              on:click={() => onEventClick(event)}
              title="{event.title}\n{new Date(event.startDate).toLocaleDateString()} - {new Date(event.endDate).toLocaleDateString()}"
            >
              <span class="event-bar-label">{event.title}</span>
            </button>
          </div>
        </div>
      {/each}
    {/if}
  </div>
</div>

<style>
  .gantt-container {
    background: var(--cream-light);
    border-radius: 20px;
    padding: 1.75rem;
    overflow-x: auto;
    border: 2px solid var(--sage-green);
    box-shadow: var(--shadow-lifted);
    position: relative;
  }

  .gantt-container::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-image:
      radial-gradient(circle, rgba(122, 158, 126, 0.03) 1px, transparent 1px);
    background-size: 12px 12px;
    pointer-events: none;
    border-radius: 20px;
  }

  .gantt-header {
    position: relative;
    height: 50px;
    margin-bottom: 1.5rem;
    border-bottom: 2px solid var(--sage-green);
    z-index: 1;
  }

  .gantt-header::after {
    content: '';
    position: absolute;
    bottom: -2px;
    left: 0;
    right: 0;
    height: 3px;
    background: linear-gradient(90deg, var(--moss-green) 0%, var(--leaf-green) 50%, var(--moss-green) 100%);
    opacity: 0.5;
  }

  .gantt-timeline {
    position: relative;
    height: 100%;
  }

  .month-marker {
    position: absolute;
    top: 0;
    height: 100%;
  }

  .month-label {
    font-size: 0.9rem;
    color: var(--forest-green);
    font-weight: 600;
    font-family: 'Nunito', sans-serif;
    letter-spacing: 0.5px;
    text-transform: uppercase;
  }

  .gantt-body {
    min-height: 250px;
    position: relative;
    z-index: 1;
  }

  .gantt-row {
    margin-bottom: 1rem;
  }

  .event-label {
    font-size: 0.875rem;
    font-weight: 600;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    font-family: 'Merriweather', serif;
    color: var(--forest-green);
  }

  .event-timeline {
    position: relative;
    height: 48px;
    background: var(--cream);
    border-radius: 12px;
    border: 2px solid var(--sage-green);
    box-shadow: inset 0 1px 3px rgba(45, 62, 47, 0.08);
  }

  .event-bar {
    position: absolute;
    height: 100%;
    border-radius: 10px;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    padding: 0 0.875rem;
    border: 2px solid rgba(0, 0, 0, 0.1);
    color: white;
    font-weight: 600;
    font-size: 0.85rem;
    font-family: 'Nunito', sans-serif;
    letter-spacing: 0.3px;
    box-shadow: var(--shadow-card);
  }

  .event-bar:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-soft);
    z-index: 10;
  }

  .event-bar-label {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    text-shadow: 2px 2px 0px rgba(0, 0, 0, 0.5);
  }

  .empty-state {
    text-align: center;
    padding: 4rem 2rem;
    color: var(--text-secondary);
    font-family: 'Nunito', sans-serif;
  }

  .empty-state p:first-child {
    font-size: 1.5rem;
    font-weight: 700;
    font-family: 'Merriweather', serif;
    color: var(--forest-green);
    margin-bottom: 0.5rem;
    letter-spacing: 0.5px;
  }

  .empty-hint {
    font-size: 1rem;
    margin-top: 0.75rem;
  }

  @media (max-width: 768px) {
    .gantt-container {
      padding: 1rem;
    }

    .month-label {
      font-size: 0.75rem;
      letter-spacing: 1px;
      writing-mode: horizontal-tb;
    }

    .gantt-header {
      height: 40px;
    }

    .gantt-row {
      grid-template-columns: 1fr;
    }

    .event-label {
      font-size: 0.7rem;
    }

    .event-bar {
      font-size: 0.7rem;
      padding: 0 0.5rem;
    }
  }

  @media (max-width: 480px) {
    .month-label {
      font-size: 0.65rem;
      letter-spacing: 0.5px;
    }

    .event-bar {
      font-size: 0.6rem;
    }
  }
</style>
