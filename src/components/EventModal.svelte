<script>
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

  function handleStartDateChange() {
    if (startDate && !endDate) {
      // Auto-focus end date input after a short delay
      setTimeout(() => {
        document.getElementById('endDate')?.focus();
      }, 100);
    }
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
          <label for="startDate">Start Date *</label>
          <input
            id="startDate"
            type="date"
            bind:value={startDate}
            on:change={handleStartDateChange}
            required
          />
        </div>

        <div class="form-group">
          <label for="endDate">End Date *</label>
          <input
            id="endDate"
            type="date"
            bind:value={endDate}
            min={startDate}
            required
          />
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
            <span class="color-text">{color}</span>
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
  .days-selector {
    display: flex;
    gap: 0.5rem;
    flex-wrap: wrap;
  }

  .day-button {
    padding: 0.5rem 0.75rem;
    border: 2px solid var(--border-color);
    background-color: var(--bg-secondary);
    color: var(--text-primary);
    border-radius: 0.375rem;
    font-size: 0.75rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
  }

  .day-button:hover {
    border-color: var(--lime-dark);
    background-color: var(--bg-tertiary);
  }

  .day-button.selected {
    background-color: var(--lime-dark);
    color: white;
    border-color: var(--lime-dark);
  }

  .color-picker {
    display: flex;
    align-items: center;
    gap: 0.75rem;
  }

  .color-preview {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    border: 2px solid var(--border-color);
    cursor: pointer;
    transition: transform 0.2s;
  }

  .color-preview:hover {
    transform: scale(1.1);
  }

  .color-picker input[type="color"] {
    width: 0;
    height: 0;
    opacity: 0;
    position: absolute;
  }

  .color-text {
    font-family: monospace;
    font-size: 0.875rem;
    color: var(--text-secondary);
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
