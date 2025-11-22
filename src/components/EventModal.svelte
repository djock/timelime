<script>
  export let event = null;
  export let onSave;
  export let onClose;

  let title = event?.title || '';
  let startDate = event?.startDate || '';
  let endDate = event?.endDate || '';
  let checkInType = event?.checkInType || 'daily';
  let color = event?.color || '#32cd32';

  function handleSubmit() {
    if (!title || !startDate || !endDate) {
      alert('Please fill in all required fields');
      return;
    }

    if (new Date(startDate) > new Date(endDate)) {
      alert('Start date must be before end date');
      return;
    }

    const eventData = {
      id: event?.id || Date.now().toString(),
      title,
      startDate,
      endDate,
      checkInType,
      color,
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
            required
          />
        </div>

        <div class="form-group">
          <label for="endDate">End Date *</label>
          <input
            id="endDate"
            type="date"
            bind:value={endDate}
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
          </select>
        </div>

        <div class="form-group">
          <label for="color">Event Color</label>
          <input
            id="color"
            type="color"
            bind:value={color}
          />
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
