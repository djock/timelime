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
    padding: 0.75rem 1rem;
    background: linear-gradient(to bottom, #FFFEF8, var(--parchment-light));
    color: var(--text-primary);
    border: 2px solid var(--border-ornate);
    border-radius: 6px;
    font-size: 0.95rem;
    font-family: 'Crimson Pro', serif;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow:
      inset 0 2px 4px var(--shadow-light),
      0 2px 6px var(--shadow-light);
  }

  .date-button:hover {
    border-color: var(--gold-accent);
    background: #FFFEF8;
    transform: translateY(-1px);
    box-shadow:
      inset 0 2px 4px var(--shadow-light),
      0 0 0 3px var(--glow-gold),
      0 4px 12px var(--shadow-medium);
  }

  .calendar-popup {
    position: absolute;
    top: 100%;
    left: 0;
    margin-top: 0.75rem;
    background: linear-gradient(to bottom, var(--parchment-light), var(--parchment-medium));
    border: 3px solid var(--border-ornate);
    border-radius: 8px;
    padding: 1.5rem;
    box-shadow:
      0 0 0 1px var(--leather-dark),
      0 15px 35px var(--shadow-deep);
    z-index: 1000;
    min-width: 340px;
  }

  .calendar-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
    padding-bottom: 0.75rem;
    border-bottom: 2px solid var(--border-ornate);
  }

  .calendar-header span {
    font-family: 'Cinzel', serif;
    font-weight: 700;
    color: var(--text-gold);
    font-size: 1rem;
    letter-spacing: 0.5px;
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
    color: var(--crimson-primary);
    font-weight: 700;
    font-family: 'Crimson Pro', serif;
    margin-bottom: 1.25rem;
    padding: 0.75rem;
    background: linear-gradient(to bottom,
      rgba(212, 175, 55, 0.2),
      rgba(232, 220, 196, 0.3)
    );
    border-radius: 6px;
    border: 2px solid var(--border-ornate);
  }

  .calendar-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    gap: 0.375rem;
  }

  .day-header {
    text-align: center;
    font-size: 0.75rem;
    font-weight: 700;
    font-family: 'Cinzel', serif;
    color: var(--text-gold);
    padding: 0.625rem 0;
    text-transform: uppercase;
    letter-spacing: 0.3px;
  }

  .calendar-day {
    aspect-ratio: 1;
    border: 2px solid var(--border-ornate);
    background: linear-gradient(145deg, var(--parchment-light), #FFFEF8);
    border-radius: 4px;
    font-size: 0.9rem;
    font-weight: 600;
    font-family: 'Crimson Pro', serif;
    cursor: pointer;
    transition: all 0.3s ease;
    padding: 0;
    color: var(--text-primary);
    box-shadow:
      0 2px 4px var(--shadow-light),
      inset 0 1px 0 rgba(255, 255, 255, 0.5);
  }

  .calendar-day:hover:not(:disabled) {
    background: linear-gradient(145deg, var(--gold-dark), #8B6914);
    color: var(--text-light);
    border-color: var(--gold-accent);
    transform: translateY(-2px);
    box-shadow:
      0 4px 8px var(--shadow-medium),
      0 0 12px var(--glow-gold);
  }

  .calendar-day.empty {
    background: transparent;
    border-color: transparent;
    cursor: default;
    box-shadow: none;
  }

  .calendar-day.selected {
    background: linear-gradient(145deg, var(--crimson-primary), var(--crimson-dark));
    color: var(--text-light);
    border-color: var(--gold-accent);
    font-weight: 900;
    box-shadow:
      0 0 15px var(--glow-crimson),
      0 4px 8px var(--shadow-medium),
      inset 0 1px 0 rgba(255, 255, 255, 0.2);
  }

  .calendar-day.in-range {
    background: linear-gradient(145deg, rgba(212, 175, 55, 0.3), rgba(232, 220, 196, 0.5));
    border-color: var(--gold-dark);
  }

  .calendar-footer {
    margin-top: 1.25rem;
    padding-top: 1.25rem;
    border-top: 2px solid var(--border-ornate);
    display: flex;
    justify-content: flex-end;
  }
</style>
