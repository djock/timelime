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
    background: var(--moss-green-light);
    color: var(--forest-green);
    border: 2px solid var(--moss-green);
    border-radius: 12px;
    font-family: 'Nunito', sans-serif;
    font-weight: 600;
    font-size: 0.95rem;
    text-align: center;
    box-shadow: var(--shadow-card);
  }

  .days-selector {
    display: flex;
    gap: 0.625rem;
    flex-wrap: wrap;
  }

  .day-button {
    padding: 0.625rem 1rem;
    border: 2px solid var(--sage-green);
    background: var(--cream-light);
    color: var(--text-primary);
    border-radius: 12px;
    font-size: 0.8rem;
    font-weight: 600;
    font-family: 'Nunito', sans-serif;
    letter-spacing: 0.3px;
    text-transform: uppercase;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: var(--shadow-card);
  }

  .day-button:hover {
    border-color: var(--moss-green);
    background: var(--sage-green);
    color: var(--forest-green);
    transform: translateY(-2px);
    box-shadow: var(--shadow-soft);
  }

  .day-button.selected {
    background: var(--moss-green);
    color: var(--text-light);
    border-color: var(--moss-green-dark);
    box-shadow: var(--shadow-soft);
  }

  .color-picker {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .color-preview {
    width: 50px;
    height: 50px;
    border-radius: 12px;
    border: 2px solid var(--sage-green);
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: var(--shadow-card);
    position: relative;
  }

  .color-preview:hover {
    transform: translateY(-2px) scale(1.05);
    border-color: var(--moss-green);
    box-shadow: var(--shadow-soft);
  }

  .color-picker input[type="color"] {
    width: 0;
    height: 0;
    opacity: 0;
    position: absolute;
  }

  .color-text {
    font-family: 'Nunito', sans-serif;
    font-size: 0.95rem;
    color: var(--text-secondary);
    font-weight: 600;
  }
</style>
