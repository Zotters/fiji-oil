let timerInterval = null;

window.addEventListener("message", (event) => {
  const data = event.data;

  if (data.action === "showValveTimer") {
    startValveTimer(data.duration);
  }

  if (data.action === "hideValveTimer") {
    stopValveTimer();
  }
});

function startValveTimer(duration) {
  const timerEl = document.getElementById("valve-timer");
  const textEl = document.getElementById("timer-text");
  const fillEl = document.querySelector(".fill");

  timerEl.classList.remove("hidden");

  let remaining = duration;
  const total = duration;

  updateCircle(remaining, total);
  updateColor(remaining);
  textEl.textContent = `${remaining}s`;

  clearInterval(timerInterval);
  timerInterval = setInterval(() => {
    remaining--;
    if (remaining <= 0) {
      stopValveTimer();
    } else {
      updateCircle(remaining, total);
      updateColor(remaining);
      textEl.textContent = `${remaining}s`;
    }
  }, 1000);
}

function stopValveTimer() {
  clearInterval(timerInterval);
  document.getElementById("valve-timer").classList.add("hidden");
}

function updateCircle(remaining, total) {
  const circle = document.querySelector(".fill");
  const percent = remaining / total;
  const offset = 283 * (1 - percent);
  circle.style.strokeDashoffset = offset;
}

function updateColor(remaining) {
  const circle = document.querySelector(".fill");

  if (remaining <= 30) {
    circle.style.stroke = "#ff4d4d"; // red
  } else if (remaining <= 60) {
    circle.style.stroke = "#ffcc00"; // yellow
  } else {
    circle.style.stroke = "#00c896"; // green
  }
}

window.addEventListener("message", (event) => {
    const data = event.data;
  
    if (data.action === "updateRefinery") {
      updateRefineryPanel(data.payload);
    }
  
    if (data.action === "showRefinery") {
      const panel = document.getElementById("refinery-panel");
      panel.classList.remove("hidden");
    
      const position = data.position || "bottom-middle";
      panel.className = `refinery-panel ${position}`;
    }
  
    if (data.action === "hideRefinery") {
      document.getElementById("refinery-panel").classList.add("hidden");
    }
  
    if (data.action === "updatePhaseProgress") {
      updatePhaseProgress(data.label, data.current, data.total, data.duration);
    }
  });
    
  function updateRefineryPanel(payload) {
    document.getElementById("ref-oil").textContent = payload.oilLabel || "—";
    document.getElementById("ref-hopper").textContent = `${payload.hopperCount || 0}/${payload.maxFill || 4}`;
    document.getElementById("ref-phase").textContent = payload.phase || "Idle";
  
    // Apply position class
    const panel = document.getElementById("refinery-panel");
    const position = payload.position || "bottom-middle";
  
    panel.classList.remove(
      "top-left", "top-middle", "top-right",
      "bottom-left", "bottom-middle", "bottom-right",
      "left-middle", "right-middle"
    );
    panel.classList.add(position);
  }
  

  function updatePhaseProgress(label, current, total, duration) {
    const fill = document.getElementById("ref-progress-fill");
    const text = document.getElementById("ref-progress-label");
  
    // Reset to 0% instantly
    fill.style.transition = "none";
    fill.style.width = "0%";
    void fill.offsetWidth; // Force reflow
  
    // Animate to 100% over the duration
    fill.style.transition = `width ${duration}ms linear`;
    fill.style.width = "100%";
  
    // Update label
    text.textContent = `${label} (${current}/${total})`;
  }
  
    
  