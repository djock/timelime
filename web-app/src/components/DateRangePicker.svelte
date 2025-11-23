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
      // Don't auto-close - user must click Save button
      selectingStart = true;
    }
  }

  function handleSave() {
    if (tempStart && tempEnd) {
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
    return dateStr === tempStart || dateStr === tempEnd;
  }

  function isInRange(date) {
    if (!date || !tempStart || !tempEnd) return false;
    const dateStr = date.toISOString().split('T')[0];
    return dateStr > tempStart && dateStr < tempEnd;
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
        <button type="button" class="secondary" on:click={() => { showCalendar = false; selectingStart = true; tempStart = startDate; tempEnd = endDate; }}>
          Cancel
        </button>
        <button type="button" on:click={handleSave} disabled={!tempStart || !tempEnd}>
          Save Range
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
    padding: 0.75rem 1rem;
    background: var(--comic-white);
    color: var(--text-primary);
    border: var(--border-medium) solid var(--comic-black);
    border-radius: 0;
    font-size: 0.95rem;
    font-family: 'Comic Neue', sans-serif;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.2s ease;
    box-shadow: 2px 2px 0px rgba(0, 0, 0, 0.3);
  }

  .date-button:hover {
    border-color: var(--comic-blue);
    background: var(--comic-white);
    transform: translate(-1px, -1px);
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.5);
  }

  .calendar-popup {
    position: absolute;
    top: 100%;
    left: 0;
    margin-top: 0.75rem;
    background: var(--comic-white);
    border: var(--border-thick) solid var(--comic-black);
    border-radius: 0;
    padding: 1.5rem;
    box-shadow: var(--shadow-comic-lg);
    z-index: 1000;
    min-width: 340px;
  }

  .calendar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
    padding-bottom: 0.75rem;
    border-bottom: var(--border-medium) solid var(--comic-black);
  }

  .calendar-header span {
    font-family: 'Bebas Neue', sans-serif;
    font-weight: 400;
    color: var(--comic-black);
    font-size: 1.1rem;
    letter-spacing: 1.5px;
    text-transform: uppercase;
  }

  .calendar-header button {
    padding: 0.375rem 0.75rem;
    min-width: auto;
    font-size: 0.9rem;
  }

  .calendar-instruction {
    text-align: center;
    font-size: 0.9rem;
    color: var(--comic-white);
    font-weight: 700;
    font-family: 'Bebas Neue', sans-serif;
    letter-spacing: 1.5px;
    margin-bottom: 1.25rem;
    padding: 0.75rem;
    background: var(--comic-red);
    border-radius: 0;
    border: var(--border-medium) solid var(--comic-black);
    box-shadow: 2px 2px 0px rgba(0, 0, 0, 0.4);
  }

  .calendar-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 0.375rem;
  }

  .day-header {
    text-align: center;
    font-size: 0.75rem;
    font-weight: 400;
    font-family: 'Bebas Neue', sans-serif;
    color: var(--comic-black);
    padding: 0.625rem 0;
    text-transform: uppercase;
    letter-spacing: 1px;
  }

  .calendar-day {
    aspect-ratio: 1;
    border: 2px solid var(--comic-black);
    background: var(--comic-white);
    border-radius: 0;
    font-size: 0.9rem;
    font-weight: 700;
    font-family: 'Comic Neue', sans-serif;
    cursor: pointer;
    transition: all 0.2s ease;
    padding: 0;
    color: var(--text-primary);
    box-shadow: 1px 1px 0px rgba(0, 0, 0, 0.3);
  }

  .calendar-day:hover:not(:disabled) {
    background: var(--comic-yellow);
    color: var(--comic-black);
    border-color: var(--comic-black);
    transform: translate(-1px, -1px);
    box-shadow: 2px 2px 0px rgba(0, 0, 0, 0.5);
  }

  .calendar-day.empty {
    background: transparent;
    border-color: transparent;
    cursor: default;
    box-shadow: none;
  }

  .calendar-day.selected {
    background: var(--comic-red);
    color: var(--comic-white);
    border-color: var(--comic-black);
    font-weight: 700;
    box-shadow: 2px 2px 0px rgba(0, 0, 0, 0.6);
  }

  .calendar-day.in-range {
    background: var(--comic-blue);
    color: var(--comic-white);
    border-color: var(--comic-black);
    opacity: 0.7;
  }

  .calendar-day.in-range:hover {
    opacity: 1;
  }

  .calendar-footer {
    margin-top: 1.25rem;
    padding-top: 1.25rem;
    border-top: var(--border-medium) solid var(--comic-black);
    display: flex;
    justify-content: space-between;
    gap: 0.75rem;
  }

  .calendar-footer button {
    flex: 1;
  }
</style>
