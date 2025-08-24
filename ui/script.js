let valveTimer = null;
let deliveryTimer = null;

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'showValveTimer') {
        showValveTimer(data.duration);
    } else if (data.action === 'updateValveTimer') {
        updateValveTimer(data.time);
    } else if (data.action === 'hideValveTimer') {
        hideValveTimer();
    }
    
    else if (data.action === 'showDeliveryTimer') {
        showDeliveryTimer(data.time);
    } else if (data.action === 'updateDeliveryTimer') {
        updateDeliveryTimer(data.time);
    } else if (data.action === 'hideDeliveryTimer') {
        hideDeliveryTimer();
    }
    
    else if (data.action === 'showRefinery') {
        showRefineryPanel();
    } else if (data.action === 'updateRefinery') {
        updateRefineryPanel(data.payload);
    } else if (data.action === 'hideRefinery') {
        hideRefineryPanel();
    }
    
    else if (data.action === 'updatePhaseProgress') {
        updatePhaseProgress(data.label, data.current, data.total, data.duration);
    }
});

function showValveTimer(duration) {
    const valveTimerElement = document.getElementById('valve-timer');
    const timerTextElement = document.getElementById('timer-text');
    const fillElement = document.querySelector('#valve-timer .fill');
    
    valveTimer = duration;
    timerTextElement.textContent = formatTime(duration);
    
    const circumference = 2 * Math.PI * 45;
    fillElement.style.strokeDasharray = circumference;
    fillElement.style.strokeDashoffset = 0;
    
    valveTimerElement.classList.remove('hidden');
    
    updateValveTimer(duration);
}

function updateValveTimer(time) {
    if (time <= 0) {
        hideValveTimer();
        return;
    }
    
    const valveTimerElement = document.getElementById('valve-timer');
    if (valveTimerElement.classList.contains('hidden')) {
        return;
    }
    
    const timerTextElement = document.getElementById('timer-text');
    const fillElement = document.querySelector('#valve-timer .fill');
    
    timerTextElement.textContent = formatTime(time);
    
    const circumference = 2 * Math.PI * 45;
    const offset = circumference * (1 - time / valveTimer);
    fillElement.style.strokeDashoffset = offset;
    
    if (time <= 30) {
        fillElement.style.stroke = '#ff3d00';
    } else {
        fillElement.style.stroke = '#00c896';
    }
}

function hideValveTimer() {
    const valveTimerElement = document.getElementById('valve-timer');
    valveTimerElement.classList.add('hidden');
}

function showDeliveryTimer(duration) {
    const deliveryTimerElement = document.getElementById('delivery-timer');
    const timerTextElement = document.getElementById('delivery-timer-text');
    const fillElement = document.querySelector('#delivery-timer .fill');
    
    deliveryTimer = duration;
    timerTextElement.textContent = formatTime(duration);
    
    const circumference = 2 * Math.PI * 45;
    fillElement.style.strokeDasharray = circumference;
    fillElement.style.strokeDashoffset = 0;
    
    deliveryTimerElement.classList.remove('hidden');
    
    updateDeliveryTimer(duration);
}

function updateDeliveryTimer(time) {
    if (time <= 0) {
        hideDeliveryTimer();
        return;
    }
    
    const deliveryTimerElement = document.getElementById('delivery-timer');
    if (deliveryTimerElement.classList.contains('hidden')) {
        return;
    }
    
    const timerTextElement = document.getElementById('delivery-timer-text');
    const fillElement = document.querySelector('#delivery-timer .fill');
    
    timerTextElement.textContent = formatTime(time);
    
    const circumference = 2 * Math.PI * 45;
    const offset = circumference * (1 - time / deliveryTimer);
    fillElement.style.strokeDashoffset = offset;
    
    if (time <= 60) {
        fillElement.style.stroke = '#ff3d00';
    } else if (time <= 300) {
        fillElement.style.stroke = '#ffa500';
    } else {
        fillElement.style.stroke = '#00a2ff';
    }
}

function hideDeliveryTimer() {
    const deliveryTimerElement = document.getElementById('delivery-timer');
    deliveryTimerElement.classList.add('hidden');
}

function showRefineryPanel() {
    const refineryPanel = document.getElementById('refinery-panel');
    refineryPanel.classList.remove('hidden');
}

function updateRefineryPanel(data) {
    const refineryPanel = document.getElementById('refinery-panel');
    const oilElement = document.getElementById('ref-oil');
    const hopperElement = document.getElementById('ref-hopper');
    const phaseElement = document.getElementById('ref-phase');
    const progressFill = document.getElementById('ref-progress-fill');
    
    const position = data.position || 'top-middle';
    refineryPanel.className = '';
    refineryPanel.classList.add(position);
    
    oilElement.textContent = data.oilLabel || '—';
    hopperElement.textContent = `${data.hopperCount || 0}/${data.maxFill || 10}`;
    phaseElement.textContent = data.phase || 'Idle';
    
    const progress = (data.hopperCount || 0) / (data.maxFill || 10) * 100;
    progressFill.style.width = `${progress}%`;
    
    refineryPanel.classList.remove('hidden');
}

function hideRefineryPanel() {
    const refineryPanel = document.getElementById('refinery-panel');
    refineryPanel.classList.add('hidden');
}

function updatePhaseProgress(label, current, total, duration) {
    const progressLabel = document.getElementById('ref-progress-label');
    const progressFill = document.getElementById('ref-progress-fill');
    
    progressLabel.textContent = `${label} (${current}/${total})`;
    
    const progress = (current / total) * 100;
    progressFill.style.width = `${progress}%`;
    
    progressFill.style.transition = `width ${duration/1000}s linear`;
}

function formatTime(seconds) {
    if (seconds < 60) {
        return `${seconds}s`;
    } else {
        const minutes = Math.floor(seconds / 60);
        const remainingSeconds = seconds % 60;
        return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
    }
}

  