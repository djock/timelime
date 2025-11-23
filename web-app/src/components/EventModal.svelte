<script>
  import DateRangePicker from './DateRangePicker.svelte';

  export let event = null;
  export let onSave;
  export let onClose;

  let title = event?.title || '';
  let startDate = event?.startDate || '';
  let endDate = event?.endDate || '';
  let checkInType = event?.checkInType || 'daily';
  let color = event?.color || '#15616D';
  let customDays = event?.customDays || [1, 2, 3, 4, 5]; // Mon-Fri default

  const daysOfWeek = [
    { value: 0, label: 'Sunday' },
    { value: 1, label: 'Monday' },
    { value: 2, label: 'Tuesday' },
    { value: 3, label: 'Wednesday' },
    { value: 4, label: 'Thursday' },
    { value: 5, label: 'Friday' },
    { value: 6, label: 'Saturday' }
  ];

  function handleDateRangeChange(start, end) {
    startDate = start;
    endDate = end;
  }

  function toggleDay(day) {
    if (customDays.includes(day)) {
      customDays = customDays.filter(d => d !== day);
    } else {
      customDays = [...customDays, day].sort();
    }
  }

  function handleSubmit() {
    if (!title || !startDate || !endDate) {
      alert('Please fill in all required fields');
      return;
    }

    if (new Date(startDate) > new Date(endDate)) {
      alert('Start date must be before end date');
      return;
    }

    if (checkInType === 'custom' && customDays.length === 0) {
      alert('Please select at least one day for custom check-ins');
      return;
    }

    const eventData = {
      id: event?.id || Date.now().toString(),
      title,
      startDate,
      endDate,
      checkInType,
      color,
      customDays: checkInType === 'custom' ? customDays : undefined,
      createdAt: event?.createdAt || new Date().toISOString()
    };

    onSave(eventData);
  }
</script>

<div class="modal-overlay" on:click={onClose}>
  <div class="modal" on:click|stopPropagation>
    <div class="modal-header">
      <h2>{event ? 'Edit Event' : 'New Event'}</h2>
      <button class="secondary" on:click={onClose}>✕</button>
    </div>

    <div class="modal-content">
      <form on:submit|preventDefault={handleSubmit}>
        <div class="form-group">
          <label for="title">Event Title *</label>
          <input
            id="title"
            type="text"
            bind:value={title}
            placeholder="Enter event title"
            required
          />
        </div>

        <div class="form-group">
          <label>Date Range *</label>
          <DateRangePicker
            {startDate}
            {endDate}
            onChange={handleDateRangeChange}
          />
          {#if startDate && endDate}
            <div class="selected-range">
              📅 Selected: {new Date(startDate).toLocaleDateString()} - {new Date(endDate).toLocaleDateString()}
            </div>
          {/if}
        </div>

        <div class="form-group">
          <label for="checkInType">Check-in Frequency *</label>
          <select id="checkInType" bind:value={checkInType} required>
            <option value="daily">Daily</option>
            <option value="weekly">Weekly</option>
            <option value="monthly">Monthly</option>
            <option value="yearly">Yearly</option>
            <option value="custom">Custom (Select Days)</option>
          </select>
        </div>

        {#if checkInType === 'custom'}
          <div class="form-group">
            <label>Select Check-in Days *</label>
            <div class="days-selector">
              {#each daysOfWeek as day}
                <button
                  type="button"
                  class="day-button"
                  class:selected={customDays.includes(day.value)}
                  on:click={() => toggleDay(day.value)}
                >
                  {day.label.slice(0, 3)}
                </button>
              {/each}
            </div>
          </div>
        {/if}

        <div class="form-group">
          <label for="color">Event Color</label>
          <div class="color-picker">
            <div
              class="color-preview"
              style="background-color: {color}"
              on:click={() => document.getElementById('color').click()}
            ></div>
            <input
              id="color"
              type="color"
              bind:value={color}
            />
          </div>
        </div>
      </form>
    </div>

    <div class="modal-footer">
      <button class="secondary" on:click={onClose}>Cancel</button>
      <button on:click={handleSubmit}>
        {event ? 'Update' : 'Create'} Event
      </button>
    </div>
  </div>
</div>

<style>
  .selected-range {
    margin-top: 0.75rem;
    padding: 0.75rem;
    background: var(--comic-blue);
    color: var(--comic-white);
    border: var(--border-medium) solid var(--comic-black);
    border-radius: 0;
    font-family: 'Comic Neue', sans-serif;
    font-weight: 700;
    font-size: 0.95rem;
    text-align: center;
    box-shadow: 2px 2px 0px rgba(0, 0, 0, 0.4);
  }

  .days-selector {
    display: flex;
    gap: 0.625rem;
    flex-wrap: wrap;
  }

  .day-button {
    padding: 0.625rem 1rem;
    border: var(--border-medium) solid var(--comic-black);
    background: var(--comic-white);
    color: var(--comic-black);
    border-radius: 0;
    font-size: 0.8rem;
    font-weight: 400;
    font-family: 'Bebas Neue', sans-serif;
    letter-spacing: 1px;
    text-transform: uppercase;
    cursor: pointer;
    transition: all 0.2s ease;
    box-shadow: 2px 2px 0px rgba(0, 0, 0, 0.3);
  }

  .day-button:hover {
    border-color: var(--comic-black);
    background: var(--comic-yellow);
    color: var(--comic-black);
    transform: translate(-1px, -1px);
    box-shadow: 3px 3px 0px rgba(0, 0, 0, 0.5);
  }

  .day-button.selected {
    background: var(--comic-red);
    color: var(--comic-white);
    border-color: var(--comic-black);
    box-shadow: 2px 2px 0px rgba(0, 0, 0, 0.6);
  }

  .color-picker {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .color-preview {
    width: 50px;
    height: 50px;
    border-radius: 0;
    border: var(--border-medium) solid var(--comic-black);
    cursor: pointer;
    transition: all 0.2s ease;
    box-shadow: 2px 2px 0px rgba(0, 0, 0, 0.4);
    position: relative;
  }

  .color-preview:hover {
    transform: translate(-2px, -2px) rotate(-5deg);
    border-color: var(--comic-black);
    box-shadow: 4px 4px 0px rgba(0, 0, 0, 0.6);
  }

  .color-picker input[type="color"] {
    width: 0;
    height: 0;
    opacity: 0;
    position: absolute;
  }

  .color-text {
    font-family: 'Crimson Pro', monospace;
    font-size: 0.95rem;
    color: var(--text-secondary);
    font-weight: 600;
  }

  .color-preview {
    position: relative;
  }

  .color-preview::after {
    content: '';
    position: absolute;
    inset: 0;
    border-radius: 50%;
    cursor: pointer;
  }
</style>
