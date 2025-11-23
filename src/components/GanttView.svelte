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
    background: linear-gradient(to bottom,
      rgba(244, 232, 208, 0.6),
      rgba(232, 220, 196, 0.4)
    );
    border-radius: 8px;
    padding: 1.75rem;
    overflow-x: auto;
    border: 3px solid var(--border-ornate);
    box-shadow:
      0 0 0 1px var(--leather-dark),
      0 6px 20px var(--shadow-medium),
      inset 0 1px 0 rgba(255, 255, 255, 0.3);
    position: relative;
  }

  .gantt-container::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background:
      repeating-linear-gradient(
        0deg,
        transparent,
        transparent 3px,
        rgba(139, 110, 20, 0.02) 3px,
        rgba(139, 110, 20, 0.02) 6px
      );
    border-radius: 8px;
    pointer-events: none;
  }

  .gantt-header {
    position: relative;
    height: 50px;
    margin-bottom: 1.5rem;
    border-bottom: 3px solid var(--border-ornate);
    z-index: 1;
  }

  .gantt-header::after {
    content: '';
    position: absolute;
    bottom: -3px;
    left: 0;
    right: 0;
    height: 3px;
    background: linear-gradient(to right,
      transparent,
      var(--gold-accent) 10%,
      var(--gold-accent) 90%,
      transparent
    );
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
    font-size: 0.85rem;
    color: var(--text-gold);
    font-weight: 700;
    font-family: 'Cinzel', serif;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    text-shadow: 0 1px 2px var(--shadow-light);
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
    font-family: 'Crimson Pro', serif;
  }

  .event-timeline {
    position: relative;
    height: 48px;
    background: linear-gradient(to bottom,
      rgba(212, 196, 168, 0.4),
      rgba(232, 220, 196, 0.2)
    );
    border-radius: 6px;
    border: 2px solid rgba(139, 110, 20, 0.3);
    box-shadow: inset 0 2px 4px var(--shadow-light);
  }

  .event-bar {
    position: absolute;
    height: 100%;
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    padding: 0 0.875rem;
    border: 2px solid rgba(0, 0, 0, 0.3);
    color: white;
    font-weight: 600;
    font-size: 0.8rem;
    font-family: 'Cinzel', serif;
    letter-spacing: 0.3px;
    text-transform: uppercase;
    box-shadow:
      0 2px 6px var(--shadow-medium),
      inset 0 1px 0 rgba(255, 255, 255, 0.3);
  }

  .event-bar:hover {
    transform: translateY(-3px) scale(1.02);
    box-shadow:
      0 6px 16px var(--shadow-medium),
      0 0 20px rgba(212, 175, 55, 0.3),
      inset 0 1px 0 rgba(255, 255, 255, 0.4);
    border-color: var(--gold-accent);
    z-index: 10;
  }

  .event-bar-label {
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.4);
  }

  .empty-state {
    text-align: center;
    padding: 4rem 2rem;
    color: var(--text-secondary);
    font-family: 'Crimson Pro', serif;
  }

  .empty-state p:first-child {
    font-size: 1.25rem;
    font-weight: 600;
    color: var(--text-gold);
    margin-bottom: 0.5rem;
  }

  .empty-hint {
    font-size: 1rem;
    margin-top: 0.75rem;
    font-style: italic;
  }

  @media (max-width: 768px) {
    .gantt-container {
      padding: 1.25rem;
    }

    .gantt-row {
      grid-template-columns: 1fr;
    }

    .event-label {
      font-size: 0.75rem;
    }

    .event-bar {
      font-size: 0.7rem;
    }
  }
</style>
