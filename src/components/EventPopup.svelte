<script>
  import { generateCheckInPeriods, isCurrentPeriod, isPastPeriod, getCurrentCheckInKey } from '../lib/dateUtils.js';

  export let event;
  export let checkIns = {};
  export let onClose;
  export let onCheckIn;
  export let onEdit;
  export let onDelete;

  $: periods = generateCheckInPeriods(event.startDate, event.endDate, event.checkInType, event.customDays);
  $: currentKey = getCurrentCheckInKey(event.checkInType, event.customDays);
  $: hasCheckedInToday = checkIns[event.id]?.[currentKey] === true;

  let canCheckIn = false;
  let completionRate = 0;

  // Check if current date is within event date range
  $: {
    const today = new Date();
    const startDate = new Date(event.startDate);
    const endDate = new Date(event.endDate);
    const isWithinRange = today >= startDate && today <= endDate;

    // For custom check-ins, also check if today is a selected day
    let isValidDay = true;
    if (event.checkInType === 'custom' && event.customDays) {
      isValidDay = event.customDays.includes(today.getDay());
    }

    canCheckIn = isWithinRange && isValidDay && isCurrentPeriod(currentKey, event.checkInType, event.customDays) && !hasCheckedInToday;
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
    const isCurrent = isCurrentPeriod(period.key, event.checkInType, event.customDays);
    const isPast = isPastPeriod(period.key, event.checkInType, event.customDays);

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
    const isPast = isPastPeriod(p.key, event.checkInType, event.customDays);
    const isChecked = checkIns[event.id]?.[p.key] === true;
    return isPast && !isChecked;
  }).length;
  $: {
    const eligiblePeriods = periods.filter(p =>
      isPastPeriod(p.key, event.checkInType, event.customDays) ||
      isCurrentPeriod(p.key, event.checkInType, event.customDays)
    ).length;
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
          <div class="stat-label">Total {event.checkInType === 'daily' ? 'Days' : event.checkInType === 'weekly' ? 'Weeks' : event.checkInType === 'monthly' ? 'Months' : event.checkInType === 'yearly' ? 'Years' : 'Check-ins'}</div>
        </div>
      </div>

      {#if canCheckIn}
        <div class="check-in-section">
          <button class="check-in-button" on:click={handleCheckIn}>
            ✓ Check In for {event.checkInType === 'daily' ? 'Today' : event.checkInType === 'weekly' ? 'This Week' : event.checkInType === 'monthly' ? 'This Month' : event.checkInType === 'yearly' ? 'This Year' : 'Today'}
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
              title="{period.key}: {checkIns[event.id]?.[period.key] ? 'Checked in' : isPastPeriod(period.key, event.checkInType, event.customDays) ? 'Missed' : 'Upcoming'}"
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
    max-width: 750px;
  }

  .event-dates {
    font-size: 1rem;
    color: var(--text-secondary);
    margin-top: 0.5rem;
    font-family: 'Crimson Pro', serif;
    font-weight: 600;
  }

  .stats {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
    gap: 1.25rem;
    margin-bottom: 2rem;
    padding: 1.5rem;
    background: linear-gradient(to bottom,
      rgba(212, 175, 55, 0.15),
      rgba(232, 220, 196, 0.2)
    );
    border-radius: 8px;
    border: 2px solid var(--border-ornate);
    box-shadow:
      0 4px 12px var(--shadow-light),
      inset 0 1px 0 rgba(255, 255, 255, 0.3);
  }

  .stat {
    text-align: center;
    position: relative;
  }

  .stat::after {
    content: '◆';
    position: absolute;
    top: -10px;
    left: 50%;
    transform: translateX(-50%);
    color: var(--gold-accent);
    font-size: 0.75rem;
    opacity: 0.6;
  }

  .stat-value {
    font-size: 2rem;
    font-weight: 900;
    font-family: 'Cinzel', serif;
    background: linear-gradient(135deg, var(--crimson-primary), var(--gold-accent));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    margin-top: 0.5rem;
  }

  .stat-label {
    font-size: 0.75rem;
    color: var(--text-secondary);
    margin-top: 0.5rem;
    font-family: 'Cinzel', serif;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: 600;
  }

  .check-in-section {
    margin-bottom: 2rem;
  }

  .check-in-button {
    width: 100%;
    padding: 1.25rem;
    font-size: 1.1rem;
    font-weight: 700;
    background: linear-gradient(145deg, var(--emerald-accent), #2E7D32);
    border: 2px solid var(--gold-dark);
    box-shadow:
      0 0 15px rgba(27, 94, 32, 0.4),
      0 6px 12px var(--shadow-medium),
      inset 0 1px 0 rgba(255, 255, 255, 0.2);
    animation: glow 2s infinite;
  }

  .check-in-button:hover {
    background: linear-gradient(145deg, #2E7D32, var(--emerald-accent));
    border-color: var(--gold-accent);
    transform: translateY(-3px);
    box-shadow:
      0 0 25px rgba(27, 94, 32, 0.6),
      0 8px 16px var(--shadow-medium),
      inset 0 1px 0 rgba(255, 255, 255, 0.3);
  }

  .contribution-section h3 {
    margin-bottom: 1.5rem;
    font-size: 1.25rem;
    font-family: 'Cinzel', serif;
    color: var(--text-gold);
    font-weight: 700;
    letter-spacing: 1px;
    text-transform: uppercase;
    text-align: center;
  }

  .contribution-cell.current {
    border: 3px solid var(--gold-accent);
    box-shadow:
      0 0 15px var(--glow-gold),
      inset 0 1px 0 rgba(255, 255, 255, 0.4);
    animation: glow 2s infinite;
  }

  .legend {
    display: flex;
    justify-content: center;
    gap: 2rem;
    margin-top: 1.5rem;
    font-size: 0.85rem;
    font-family: 'Crimson Pro', serif;
    font-weight: 600;
  }

  .legend-item {
    display: flex;
    align-items: center;
    gap: 0.625rem;
  }

  .legend-item .contribution-cell {
    width: 18px;
    height: 18px;
  }
</style>
