<script>
  import { generateCheckInPeriods, isCurrentPeriod, isPastPeriod, getCurrentCheckInKey } from '../lib/dateUtils.js';

  export let event;
  export let checkIns = {};
  export let onClose;
  export let onCheckIn;
  export let onEdit;
  export let onDelete;

  $: periods = generateCheckInPeriods(event.startDate, event.endDate, event.checkInType);
  $: currentKey = getCurrentCheckInKey(event.checkInType);
  $: hasCheckedInToday = checkIns[event.id]?.[currentKey] === true;

  let canCheckIn = false;
  let completionRate = 0;

  // Check if current date is within event date range
  $: {
    const today = new Date();
    const startDate = new Date(event.startDate);
    const endDate = new Date(event.endDate);
    const isWithinRange = today >= startDate && today <= endDate;
    canCheckIn = isWithinRange && isCurrentPeriod(currentKey, event.checkInType) && !hasCheckedInToday;
  }

  $: {
    // Calculate grid layout
    const total = periods.length;
    let cols;
    if (event.checkInType === 'daily') {
      cols = 7; // Weekly grid
    } else if (event.checkInType === 'weekly') {
      cols = 13; // Quarterly-ish
    } else if (event.checkInType === 'monthly') {
      cols = 4; // Quarterly
    } else {
      cols = Math.min(total, 10);
    }
    gridCols = cols;
  }

  let gridCols = 7;

  function getCellClass(period) {
    const isChecked = checkIns[event.id]?.[period.key] === true;
    const isCurrent = isCurrentPeriod(period.key, event.checkInType);
    const isPast = isPastPeriod(period.key, event.checkInType);

    if (isChecked) return 'checked';
    if (isPast && !isChecked) return 'missed';
    if (isCurrent) return 'current';
    return 'future';
  }

  function handleCheckIn() {
    onCheckIn(event.id, currentKey);
  }

  $: checkedCount = periods.filter(p => checkIns[event.id]?.[p.key] === true).length;
  $: missedCount = periods.filter(p => {
    const isPast = isPastPeriod(p.key, event.checkInType);
    const isChecked = checkIns[event.id]?.[p.key] === true;
    return isPast && !isChecked;
  }).length;
  $: {
    const eligiblePeriods = periods.filter(p => isPastPeriod(p.key, event.checkInType) || isCurrentPeriod(p.key, event.checkInType)).length;
    completionRate = eligiblePeriods > 0 ? Math.round((checkedCount / eligiblePeriods) * 100) : 0;
  }
</script>

<div class="modal-overlay" on:click={onClose}>
  <div class="modal event-popup" on:click|stopPropagation>
    <div class="modal-header">
      <div>
        <h2 style="color: {event.color}">{event.title}</h2>
        <p class="event-dates">
          {new Date(event.startDate).toLocaleDateString()} - {new Date(event.endDate).toLocaleDateString()}
        </p>
      </div>
      <button class="secondary" on:click={onClose}>✕</button>
    </div>

    <div class="modal-content">
      <div class="stats">
        <div class="stat">
          <div class="stat-value">{checkedCount}</div>
          <div class="stat-label">Checked In</div>
        </div>
        <div class="stat">
          <div class="stat-value">{missedCount}</div>
          <div class="stat-label">Missed</div>
        </div>
        <div class="stat">
          <div class="stat-value">{completionRate}%</div>
          <div class="stat-label">Completion</div>
        </div>
        <div class="stat">
          <div class="stat-value">{periods.length}</div>
          <div class="stat-label">Total {event.checkInType === 'daily' ? 'Days' : event.checkInType === 'weekly' ? 'Weeks' : event.checkInType === 'monthly' ? 'Months' : 'Years'}</div>
        </div>
      </div>

      {#if canCheckIn}
        <div class="check-in-section">
          <button class="check-in-button" on:click={handleCheckIn}>
            ✓ Check In for {event.checkInType === 'daily' ? 'Today' : event.checkInType === 'weekly' ? 'This Week' : event.checkInType === 'monthly' ? 'This Month' : 'This Year'}
          </button>
        </div>
      {/if}

      <div class="contribution-section">
        <h3>Progress Tracker</h3>
        <div
          class="contribution-grid"
          style="grid-template-columns: repeat({gridCols}, 1fr);"
        >
          {#each periods as period}
            <div
              class="contribution-cell {getCellClass(period)}"
              title="{period.key}: {checkIns[event.id]?.[period.key] ? 'Checked in' : isPastPeriod(period.key, event.checkInType) ? 'Missed' : 'Upcoming'}"
            ></div>
          {/each}
        </div>
        <div class="legend">
          <div class="legend-item">
            <div class="contribution-cell checked"></div>
            <span>Checked in</span>
          </div>
          <div class="legend-item">
            <div class="contribution-cell missed"></div>
            <span>Missed</span>
          </div>
          <div class="legend-item">
            <div class="contribution-cell future"></div>
            <span>Upcoming</span>
          </div>
        </div>
      </div>
    </div>

    <div class="modal-footer">
      <button class="danger" on:click={() => onDelete(event.id)}>Delete</button>
      <button class="secondary" on:click={() => onEdit(event)}>Edit</button>
      <button on:click={onClose}>Close</button>
    </div>
  </div>
</div>

<style>
  .event-popup {
    max-width: 700px;
  }

  .event-dates {
    font-size: 0.875rem;
    color: var(--text-secondary);
    margin-top: 0.25rem;
  }

  .stats {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
    gap: 1rem;
    margin-bottom: 1.5rem;
    padding: 1rem;
    background-color: var(--bg-tertiary);
    border-radius: 0.5rem;
  }

  .stat {
    text-align: center;
  }

  .stat-value {
    font-size: 1.5rem;
    font-weight: bold;
    color: var(--lime-dark);
  }

  .stat-label {
    font-size: 0.75rem;
    color: var(--text-secondary);
    margin-top: 0.25rem;
  }

  .check-in-section {
    margin-bottom: 1.5rem;
  }

  .check-in-button {
    width: 100%;
    padding: 1rem;
    font-size: 1rem;
    font-weight: bold;
    background-color: var(--success);
  }

  .check-in-button:hover {
    background-color: #16a34a;
  }

  .contribution-section h3 {
    margin-bottom: 1rem;
    font-size: 1rem;
  }

  .contribution-cell.current {
    border: 2px solid var(--lime-dark);
  }

  .legend {
    display: flex;
    gap: 1.5rem;
    margin-top: 1rem;
    font-size: 0.75rem;
  }

  .legend-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .legend-item .contribution-cell {
    width: 16px;
    height: 16px;
  }
</style>
