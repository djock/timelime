// Date utility functions

export function isLeapYear(year) {
  return (year % 4 === 0 && year % 100 !== 0) || (year % 400 === 0);
}

export function getDaysInYear(year) {
  return isLeapYear(year) ? 366 : 365;
}

export function getWeeksInYear(year) {
  // ISO week date system - most years have 52 weeks, some have 53
  const dec31 = new Date(year, 11, 31);
  const jan1 = new Date(year, 0, 1);
  const dec31Day = dec31.getDay();
  const jan1Day = jan1.getDay();

  // Years with 53 weeks: leap years starting on Thursday,
  // or non-leap years starting on Thursday and leap years starting on Wednesday
  if (dec31Day === 4 || (dec31Day === 5 && isLeapYear(year))) {
    return 53;
  }
  return 52;
}

export function getMonthsInYear() {
  return 12;
}

export function formatDate(date) {
  if (typeof date === 'string') {
    date = new Date(date);
  }
  return date.toISOString().split('T')[0];
}

export function getWeekNumber(date) {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
}

export function getMonthNumber(date) {
  return date.getMonth() + 1;
}

export function getCheckInKey(date, type) {
  const d = new Date(date);
  const year = d.getFullYear();

  switch (type) {
    case 'daily':
      return formatDate(d);
    case 'weekly':
      return `${year}-W${String(getWeekNumber(d)).padStart(2, '0')}`;
    case 'monthly':
      return `${year}-${String(d.getMonth() + 1).padStart(2, '0')}`;
    case 'yearly':
      return String(year);
    default:
      return formatDate(d);
  }
}

export function getCurrentCheckInKey(type) {
  return getCheckInKey(new Date(), type);
}

export function generateCheckInPeriods(startDate, endDate, type) {
  const start = new Date(startDate);
  const end = new Date(endDate);
  const periods = [];

  if (type === 'daily') {
    const current = new Date(start);
    while (current <= end) {
      periods.push({
        key: formatDate(current),
        date: new Date(current)
      });
      current.setDate(current.getDate() + 1);
    }
  } else if (type === 'weekly') {
    const current = new Date(start);
    const seen = new Set();
    while (current <= end) {
      const key = getCheckInKey(current, 'weekly');
      if (!seen.has(key)) {
        seen.add(key);
        periods.push({
          key,
          date: new Date(current)
        });
      }
      current.setDate(current.getDate() + 7);
    }
  } else if (type === 'monthly') {
    const current = new Date(start.getFullYear(), start.getMonth(), 1);
    while (current <= end) {
      periods.push({
        key: getCheckInKey(current, 'monthly'),
        date: new Date(current)
      });
      current.setMonth(current.getMonth() + 1);
    }
  } else if (type === 'yearly') {
    for (let year = start.getFullYear(); year <= end.getFullYear(); year++) {
      periods.push({
        key: String(year),
        date: new Date(year, 0, 1)
      });
    }
  }

  return periods;
}

export function getGridDimensions(type, startDate) {
  const year = new Date(startDate).getFullYear();

  switch (type) {
    case 'daily':
      const days = getDaysInYear(year);
      // Approximate 7 columns for weekly grid layout
      return { rows: Math.ceil(days / 7), cols: 7, total: days };
    case 'weekly':
      const weeks = getWeeksInYear(year);
      return { rows: Math.ceil(weeks / 13), cols: 13, total: weeks };
    case 'monthly':
      return { rows: 3, cols: 4, total: 12 };
    case 'yearly':
      return { rows: 1, cols: 1, total: 1 };
    default:
      return { rows: 1, cols: 1, total: 1 };
  }
}

export function isPastPeriod(periodKey, type) {
  const now = new Date();
  const currentKey = getCurrentCheckInKey(type);

  if (type === 'daily') {
    return new Date(periodKey) < new Date(formatDate(now));
  } else if (type === 'weekly') {
    return periodKey < currentKey;
  } else if (type === 'monthly') {
    return periodKey < currentKey;
  } else if (type === 'yearly') {
    return parseInt(periodKey) < now.getFullYear();
  }
  return false;
}

export function isCurrentPeriod(periodKey, type) {
  return periodKey === getCurrentCheckInKey(type);
}
