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
    background: var(--comic-white);
    border-radius: 0;
    padding: 1.75rem;
    overflow-x: auto;
    border: var(--border-thick) solid var(--comic-black);
    box-shadow: var(--shadow-comic-lg);
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
      radial-gradient(circle, rgba(0, 102, 204, 0.03) 1px, transparent 1px);
    background-size: 12px 12px;
    pointer-events: none;
  }

  .gantt-header {
    position: relative;
    height: 50px;
    margin-bottom: 1.5rem;
    border-bottom: var(--border-thick) solid var(--comic-black);
    z-index: 1;
  }

  .gantt-header::after {
    content: '';
    position: absolute;
    bottom: -4px;
    left: 0;
    right: 0;
    height: 4px;
    background:
      repeating-linear-gradient(
        90deg,
        var(--comic-red) 0px,
        var(--comic-red) 20px,
        var(--comic-yellow) 20px,
        var(--comic-yellow) 40px
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
    font-size: 0.9rem;
    color: var(--comic-black);
    font-weight: 400;
    font-family: 'Bebas Neue', sans-serif;
    letter-spacing: 1.5px;
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
    font-family: 'Crimson Pro', serif;
  }

  .event-timeline {
    position: relative;
    height: 48px;
    background: var(--comic-gray-light);
    border-radius: 0;
    border: 2px solid var(--comic-gray);
    box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
  }

  .event-bar {
    position: absolute;
    height: 100%;
    border-radius: 0;
    cursor: pointer;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    padding: 0 0.875rem;
    border: var(--border-medium) solid var(--comic-black);
    color: white;
    font-weight: 400;
    font-size: 0.85rem;
    font-family: 'Bebas Neue', sans-serif;
    letter-spacing: 1px;
    text-transform: uppercase;
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.6);
  }

  .event-bar:hover {
    transform: translate(-2px, -2px);
    box-shadow: 5px 5px 0px rgba(0, 0, 0, 0.8);
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
    font-family: 'Comic Neue', sans-serif;
  }

  .empty-state p:first-child {
    font-size: 1.5rem;
    font-weight: 700;
    font-family: 'Bebas Neue', sans-serif;
    color: var(--comic-red);
    margin-bottom: 0.5rem;
    letter-spacing: 2px;
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
