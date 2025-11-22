<script>
  export let startDate = '';
  export let endDate = '';
  export let onChange;

  let showCalendar = false;
  let currentMonth = new Date();
  let selectingStart = true; // true = selecting start, false = selecting end
  let tempStart = startDate;
  let tempEnd = endDate;

  const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  function getDaysInMonth(date) {
    const year = date.getFullYear();
    const month = date.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    const startDay = firstDay.getDay();

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
      // Apply selection
      onChange(tempStart, tempEnd);
      showCalendar = false;
      selectingStart = true;
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
    return dateStr === tempStart || dateStr === tempEnd || dateStr === startDate || dateStr === endDate;
  }

  function isInRange(date) {
    if (!date || !tempStart || !tempEnd) return false;
    const dateStr = date.toISOString().split('T')[0];
    return dateStr >= tempStart && dateStr <= tempEnd;
  }

  function formatDateRange() {
    if (!startDate && !endDate) return 'Select date range';
    if (startDate && !endDate) return `${new Date(startDate).toLocaleDateString()} - ...`;
    if (!startDate && endDate) return `... - ${new Date(endDate).toLocaleDateString()}`;
    return `${new Date(startDate).toLocaleDateString()} - ${new Date(endDate).toLocaleDateString()}`;
  }

  $: days = getDaysInMonth(currentMonth);
</script>

<div class="date-range-picker">
  <button
    type="button"
    class="date-button"
    on:click={() => { showCalendar = !showCalendar; tempStart = startDate; tempEnd = endDate; }}
  >
    📅 {formatDateRange()}
  </button>

  {#if showCalendar}
    <div class="calendar-popup">
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

        {#each days as date}
          <button
            type="button"
            class="calendar-day"
            class:empty={!date}
            class:selected={isSelected(date)}
            class:in-range={isInRange(date)}
            on:click={() => handleDateClick(date)}
            disabled={!date}
          >
            {date ? date.getDate() : ''}
          </button>
        {/each}
      </div>

      <div class="calendar-footer">
        <button type="button" class="secondary" on:click={() => { showCalendar = false; selectingStart = true; }}>
          Cancel
        </button>
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
    padding: 0.75rem;
    background-color: var(--bg-secondary);
    color: var(--text-primary);
    border: 1px solid var(--border-color);
    border-radius: 0.375rem;
    font-size: 0.875rem;
    cursor: pointer;
    transition: border-color 0.2s;
  }

  .date-button:hover {
    border-color: var(--lime-dark);
    background-color: var(--bg-secondary);
  }

  .calendar-popup {
    position: absolute;
    top: 100%;
    left: 0;
    margin-top: 0.5rem;
    background-color: var(--bg-primary);
    border: 1px solid var(--border-color);
    border-radius: 0.5rem;
    padding: 1rem;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
    z-index: 1000;
    min-width: 300px;
  }

  .calendar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 0.5rem;
    padding-bottom: 0.5rem;
    border-bottom: 1px solid var(--border-color);
  }

  .calendar-header button {
    padding: 0.25rem 0.5rem;
    min-width: auto;
  }

  .calendar-instruction {
    text-align: center;
    font-size: 0.875rem;
    color: var(--accent-secondary);
    font-weight: 600;
    margin-bottom: 1rem;
    padding: 0.5rem;
    background-color: var(--bg-secondary);
    border-radius: 0.25rem;
  }

  .calendar-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 0.25rem;
  }

  .day-header {
    text-align: center;
    font-size: 0.75rem;
    font-weight: 600;
    color: var(--text-secondary);
    padding: 0.5rem 0;
  }

  .calendar-day {
    aspect-ratio: 1;
    border: 1px solid var(--border-color);
    background-color: var(--bg-secondary);
    border-radius: 0.25rem;
    font-size: 0.875rem;
    cursor: pointer;
    transition: all 0.2s;
    padding: 0;
  }

  .calendar-day:hover:not(:disabled) {
    background-color: var(--lime-light);
    color: white;
    border-color: var(--lime-dark);
  }

  .calendar-day.empty {
    background-color: transparent;
    border-color: transparent;
    cursor: default;
  }

  .calendar-day.selected {
    background-color: var(--lime-dark);
    color: white;
    border-color: var(--lime-dark);
    font-weight: 700;
  }

  .calendar-day.in-range {
    background-color: var(--bg-tertiary);
    border-color: var(--lime-light);
  }

  .calendar-footer {
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 1px solid var(--border-color);
    display: flex;
    justify-content: flex-end;
  }
</style>
