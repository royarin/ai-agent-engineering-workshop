// Countdown to the next festival edition. The target is read from the element's data-target
// so the markup owns the date, not this script.
(function () {
    var el = document.querySelector('[data-countdown]');
    if (!el) return;
    var target = new Date(el.getAttribute('data-countdown')).getTime();
    var out = {
        days: el.querySelector('[data-days]'),
        hours: el.querySelector('[data-hours]'),
        minutes: el.querySelector('[data-minutes]'),
        seconds: el.querySelector('[data-seconds]')
    };
    function pad(n) { return (n < 10 ? '0' : '') + n; }
    function tick() {
        var diff = Math.max(0, target - Date.now());
        var s = Math.floor(diff / 1000);
        if (out.days) out.days.textContent = pad(Math.floor(s / 86400));
        if (out.hours) out.hours.textContent = pad(Math.floor((s % 86400) / 3600));
        if (out.minutes) out.minutes.textContent = pad(Math.floor((s % 3600) / 60));
        if (out.seconds) out.seconds.textContent = pad(s % 60);
    }
    tick();
    setInterval(tick, 1000);
})();
