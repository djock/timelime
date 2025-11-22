<script>
  export let events = [];
  export let selectedYear = new Date().getFullYear();
  export let onEventClick;

  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

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
          <div class="event-label">{event.title}</div>
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
    background-color: var(--bg-secondary);
    border-radius: 0.5rem;
    padding: 1rem;
    overflow-x: auto;
  }

  .gantt-header {
    position: relative;
    height: 40px;
    margin-bottom: 1rem;
    border-bottom: 2px solid var(--border-color);
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
    font-size: 0.75rem;
    color: var(--text-secondary);
    font-weight: 500;
  }

  .gantt-body {
    min-height: 200px;
  }

  .gantt-row {
    display: grid;
    grid-template-columns: 200px 1fr;
    gap: 1rem;
    margin-bottom: 0.75rem;
    align-items: center;
  }

  .event-label {
    font-size: 0.875rem;
    font-weight: 500;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .event-timeline {
    position: relative;
    height: 40px;
    background-color: var(--bg-tertiary);
    border-radius: 0.25rem;
  }

  .event-bar {
    position: absolute;
    height: 100%;
    border-radius: 0.25rem;
    cursor: pointer;
    transition: opacity 0.2s, transform 0.2s;
    display: flex;
    align-items: center;
    padding: 0 0.5rem;
    border: none;
    color: white;
    font-weight: 500;
    font-size: 0.75rem;
  }

  .event-bar:hover {
    opacity: 0.9;
    transform: translateY(-2px);
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
  }

  .event-bar-label {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .empty-state {
    text-align: center;
    padding: 3rem;
    color: var(--text-secondary);
  }

  .empty-hint {
    font-size: 0.875rem;
    margin-top: 0.5rem;
  }

  @media (max-width: 768px) {
    .gantt-row {
      grid-template-columns: 1fr;
    }

    .event-label {
      font-size: 0.75rem;
    }
  }
</style>
