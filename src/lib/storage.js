// Cookie-based storage for events and check-ins
const EVENTS_KEY = 'timelime_events';
const CHECKINS_KEY = 'timelime_checkins';
const COOKIE_EXPIRES = 365; // days

function setCookie(name, value, days) {
  const expires = new Date();
  expires.setTime(expires.getTime() + days * 24 * 60 * 60 * 1000);
  document.cookie = `${name}=${encodeURIComponent(JSON.stringify(value))};expires=${expires.toUTCString()};path=/`;
}

function getCookie(name) {
  const nameEQ = name + "=";
  const ca = document.cookie.split(';');
  for (let i = 0; i < ca.length; i++) {
    let c = ca[i];
    while (c.charAt(0) === ' ') c = c.substring(1, c.length);
    if (c.indexOf(nameEQ) === 0) {
      try {
        return JSON.parse(decodeURIComponent(c.substring(nameEQ.length, c.length)));
      } catch (e) {
        return null;
      }
    }
  }
  return null;
}

export function saveEvents(events) {
  setCookie(EVENTS_KEY, events, COOKIE_EXPIRES);
}

export function loadEvents() {
  return getCookie(EVENTS_KEY) || [];
}

export function saveCheckIns(checkIns) {
  setCookie(CHECKINS_KEY, checkIns, COOKIE_EXPIRES);
}

export function loadCheckIns() {
  return getCookie(CHECKINS_KEY) || {};
}

export function exportData() {
  const data = {
    events: loadEvents(),
    checkIns: loadCheckIns(),
    exportedAt: new Date().toISOString()
  };

  const json = JSON.stringify(data, null, 2);
  const blob = new Blob([json], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `timelime-backup-${new Date().toISOString().split('T')[0]}.json`;
  a.click();
  URL.revokeObjectURL(url);
}

export function importData(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const data = JSON.parse(e.target.result);
        if (data.events && Array.isArray(data.events)) {
          saveEvents(data.events);
        }
        if (data.checkIns && typeof data.checkIns === 'object') {
          saveCheckIns(data.checkIns);
        }
        resolve(data);
      } catch (error) {
        reject(new Error('Invalid file format'));
      }
    };
    reader.onerror = () => reject(new Error('Failed to read file'));
    reader.readAsText(file);
  });
}
