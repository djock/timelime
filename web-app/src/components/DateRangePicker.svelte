<script>
  export let startDate = '';
  export let endDate = '';
  export let onChange;

  let showCalendar = false;
  let currentMonth = new Date();
  let selectingStart = true; // true = selecting start, false = selecting end
  let tempStart = startDate;
  let tempEnd = endDate;
  let hoverDate = null; // Track the date being hovered over

  const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  const daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  function getDaysInMonth(date) {
    const year = date.getFullYear();
    const month = date.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    let startDay = firstDay.getDay();

    // Convert Sunday (0) to 6, and shift Monday (1) to 0
    startDay = startDay === 0 ? 6 : startDay - 1;

    const days = [];

    // Add empty cells for days before month starts
    for (let i = 0; i < startDay; i++) {
      days.push(null);
    }

    // Add days of month
    for (let day = 1; day <= daysInMonth; day++) {
      days.push(new Date(year, month, day));
    }

    return days;
  }

  function handleDateClick(date) {
    if (!date) return;

    const dateStr = date.toISOString().split('T')[0];

    if (selectingStart) {
      tempStart = dateStr;
      tempEnd = ''; // Reset end date
      selectingStart = false;
    } else {
      if (new Date(dateStr) < new Date(tempStart)) {
        // If end date is before start, swap them
        tempEnd = tempStart;
        tempStart = dateStr;
      } else {
        tempEnd = dateStr;
      }
      // Don't auto-close - user must click Save button
      selectingStart = true;
    }
  }

  function handleSave() {
    if (tempStart && tempEnd) {
      onChange(tempStart, tempEnd);
      showCalendar = false;
      selectingStart = true;
      hoverDate = null;
    }
  }

  function nextMonth() {
    currentMonth = new Date(currentMonth.getFullYear(), currentMonth.getMonth() + 1, 1);
  }

  function prevMonth() {
    currentMonth = new Date(currentMonth.getFullYear(), currentMonth.getMonth() - 1, 1);
  }

  function isSelected(date) {
    if (!date) return false;
    const dateStr = date.toISOString().split('T')[0];
    return dateStr === tempStart || dateStr === tempEnd;
  }

  function isInRange(date) {
    if (!date) return false;
    const dateStr = date.toISOString().split('T')[0];

    // If we have both start and end, show the confirmed range
    if (tempStart && tempEnd) {
      return dateStr > tempStart && dateStr < tempEnd;
    }

    // If we only have start date and are hovering, show preview range
    if (tempStart && !tempEnd && hoverDate && !selectingStart) {
      const hoverStr = hoverDate.toISOString().split('T')[0];
      const inRange = (hoverStr > tempStart && dateStr > tempStart && dateStr < hoverStr) ||
                      (hoverStr < tempStart && dateStr > hoverStr && dateStr < tempStart);
      return inRange;
    }

    return false;
  }

  function isHoverEnd(date) {
    if (!date || !tempStart || tempEnd || selectingStart || !hoverDate) return false;
    const dateStr = date.toISOString().split('T')[0];
    const hoverStr = hoverDate.toISOString().split('T')[0];
    return dateStr === hoverStr;
  }

  function isPastDate(date) {
    if (!date) return false;
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const checkDate = new Date(date);
    checkDate.setHours(0, 0, 0, 0);
    return checkDate < today;
  }

  function formatDateRange() {
    if (!startDate && !endDate) return 'Select date range';
    if (startDate && !endDate) return `${new Date(startDate).toLocaleDateString()} - ...`;
    if (!startDate && endDate) return `... - ${new Date(endDate).toLocaleDateString()}`;
    return `${new Date(startDate).toLocaleDateString()} - ${new Date(endDate).toLocaleDateString()}`;
  }

  $: days = getDaysInMonth(currentMonth);

  // Create a reactive key that changes when any selection state changes
  $: selectionKey = `${tempStart}-${tempEnd}-${hoverDate?.toISOString() || 'none'}-${selectingStart}`;
</script>

<div class="date-range-picker">
  <button
    type="button"
    class="date-button"
    on:click={() => {
      showCalendar = !showCalendar;
      tempStart = startDate;
      tempEnd = endDate;
      selectingStart = true;
      hoverDate = null;
    }}
  >
    📅 {formatDateRange()}
  </button>

{#if showCalendar}
    <div class="calendar-modal-overlay" on:click={() => {
      showCalendar = false;
      selectingStart = true;
      tempStart = startDate;
      tempEnd = endDate;
      hoverDate = null;
    }}>
      <div class="calendar-modal" on:click|stopPropagation>
        <div class="calendar-modal-header">
          <h3>Select Date Range</h3>
          <button type="button" class="close-button" on:click={() => {
            showCalendar = false;
            selectingStart = true;
            tempStart = startDate;
            tempEnd = endDate;
            hoverDate = null;
          }}>✕</button>
        </div>

        <div class="calendar-modal-content">
          <div class="calendar-header">
            <button type="button" on:click={prevMonth}>◀</button>
            <span>{monthNames[currentMonth.getMonth()]} {currentMonth.getFullYear()}</span>
            <button type="button" on:click={nextMonth}>▶</button>
          </div>

          <div class="calendar-instruction">
            {selectingStart ? '1️⃣ Select start date' : '2️⃣ Select end date'}
          </div>

          <div class="calendar-grid">
            {#each daysOfWeek as day}
              <div class="day-header">{day}</div>
            {/each}

            {#key selectionKey}
              {#each days as date}
                <button
                  type="button"
                  class="calendar-day"
                  class:empty={!date}
                  class:selected={isSelected(date)}
                  class:in-range={isInRange(date)}
                  class:hover-end={isHoverEnd(date)}
                  class:past={isPastDate(date)}
                  on:click={() => handleDateClick(date)}
                  on:mouseenter={() => {
                    if (!selectingStart && tempStart && !tempEnd && !isPastDate(date)) {
                      hoverDate = date;
                    }
                  }}
                  on:mouseleave={() => {
                    if (!selectingStart && tempStart && !tempEnd) {
                      hoverDate = null;
                    }
                  }}
                  disabled={!date || isPastDate(date)}
                >
                  {date ? date.getDate() : ''}
                </button>
              {/each}
            {/key}
          </div>

          <div class="calendar-footer">
            <button type="button" class="secondary" on:click={() => {
              showCalendar = false;
              selectingStart = true;
              tempStart = startDate;
              tempEnd = endDate;
              hoverDate = null;
            }}>
              Cancel
            </button>
            <button type="button" on:click={handleSave} disabled={!tempStart || !tempEnd}>
              Save Range
            </button>
          </div>
        </div>
      </div>
    </div>
  {/if}
</div>

<style>
  .date-range-picker {
    position: relative;
  }

  .date-button {
    width: 100%;
    text-align: left;
    padding: 0.75rem 1rem;
    background: var(--cream-light);
    color: var(--text-primary);
    border: 2px solid var(--sage-green);
    border-radius: 12px;
    font-size: 0.95rem;
    font-family: 'Nunito', sans-serif;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: var(--shadow-card);
  }

  .date-button:hover {
    border-color: var(--moss-green);
    background: var(--cream);
    transform: translateY(-2px);
    box-shadow: var(--shadow-soft);
  }

  .calendar-modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(45, 75, 62, 0.75);
    backdrop-filter: blur(4px);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 2000;
    padding: 1rem;
  }

  .calendar-modal {
    background: var(--cream-light);
    border: 2px solid var(--sage-green);
    border-radius: 20px;
    box-shadow: var(--shadow-lifted);
    max-width: 500px;
    width: 100%;
    max-height: 90vh;
    overflow-y: auto;
  }

  .calendar-modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1.5rem;
    border-bottom: 2px solid var(--sage-green);
    background: var(--cream);
    border-radius: 20px 20px 0 0;
  }

  .calendar-modal-header h3 {
    margin: 0;
    font-family: 'Merriweather', serif;
    font-size: 1.5rem;
    letter-spacing: 0.5px;
    color: var(--forest-green);
    font-weight: 600;
  }

  .close-button {
    padding: 0.5rem 0.75rem;
    background: var(--terracotta);
    color: var(--text-light);
    border: 2px solid var(--terracotta-dark);
    border-radius: 12px;
    font-size: 1.25rem;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: var(--shadow-card);
    min-width: auto;
  }

  .close-button:hover {
    background: var(--terracotta-dark);
    border-color: var(--terracotta-dark);
    transform: translateY(-2px);
    box-shadow: var(--shadow-soft);
  }

  .calendar-modal-content {
    padding: 1.5rem;
  }

  .calendar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
    padding-bottom: 0.75rem;
    border-bottom: 2px solid var(--sage-green);
  }

  .calendar-header span {
    font-family: 'Merriweather', serif;
    font-weight: 600;
    color: var(--forest-green);
    font-size: 1.1rem;
    letter-spacing: 0.5px;
  }

  .calendar-header button {
    padding: 0.375rem 0.75rem;
    min-width: auto;
    font-size: 0.9rem;
  }

  .calendar-instruction {
    text-align: center;
    font-size: 0.9rem;
    color: var(--text-light);
    font-weight: 600;
    font-family: 'Nunito', sans-serif;
    letter-spacing: 0.5px;
    margin-bottom: 1.25rem;
    padding: 0.75rem;
    background: var(--moss-green);
    border-radius: 12px;
    border: 2px solid var(--moss-green-dark);
    box-shadow: var(--shadow-card);
  }

  .calendar-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 0.5rem;
  }

  .day-header {
    text-align: center;
    font-size: 0.75rem;
    font-weight: 600;
    font-family: 'Nunito', sans-serif;
    color: var(--text-secondary);
    padding: 0.625rem 0;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .calendar-day {
    aspect-ratio: 1;
    border: 2px solid var(--sage-green);
    background: var(--cream-light);
    border-radius: 10px;
    font-size: 0.9rem;
    font-weight: 600;
    font-family: 'Nunito', sans-serif;
    cursor: pointer;
    transition: all 0.3s ease;
    padding: 0;
    color: var(--text-primary);
    box-shadow: var(--shadow-card);
  }

  .calendar-day:hover:not(:disabled) {
    background: var(--sage-green);
    color: var(--forest-green);
    border-color: var(--moss-green);
    transform: translateY(-2px);
    box-shadow: var(--shadow-soft);
  }

  .calendar-day.empty {
    background: transparent;
    border-color: transparent;
    cursor: default;
    box-shadow: none;
  }

  .calendar-day.past {
    background: var(--cream-dark);
    color: var(--text-secondary);
    border-color: var(--cream-dark);
    cursor: not-allowed;
    opacity: 0.5;
    box-shadow: none;
  }

  .calendar-day.past:hover {
    background: var(--cream-dark);
    color: var(--text-secondary);
    border-color: var(--cream-dark);
    transform: none;
    box-shadow: none;
  }

  .calendar-day.selected {
    background: var(--terracotta);
    color: var(--text-light);
    border-color: var(--terracotta-dark);
    font-weight: 700;
    box-shadow: var(--shadow-soft);
  }

  .calendar-day.in-range {
    background: var(--moss-green-light);
    color: var(--forest-green);
    border-color: var(--moss-green);
    opacity: 0.85;
    box-shadow: var(--shadow-card);
  }

  .calendar-day.in-range:hover {
    opacity: 1;
    border-color: var(--moss-green-dark);
    transform: translateY(-2px);
    box-shadow: var(--shadow-soft);
  }

  .calendar-day.hover-end {
    background: var(--terracotta-light);
    color: var(--text-light);
    border-color: var(--terracotta);
    opacity: 0.8;
    box-shadow: var(--shadow-soft);
    font-weight: 700;
  }

  .calendar-day.hover-end:hover {
    opacity: 1;
  }

  .calendar-footer {
    margin-top: 1.25rem;
    padding-top: 1.25rem;
    border-top: 2px solid var(--sage-green);
    display: flex;
    justify-content: space-between;
    gap: 0.75rem;
  }

  .calendar-footer button {
    flex: 1;
  }
</style>
