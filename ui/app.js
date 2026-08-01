(function () {
  'use strict';

  const resourceName = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : (window.GetParentResourceName ? window.GetParentResourceName() : 'fiji-oil');

  // Mock responses used only when fetch fails (i.e. this page is being
  // previewed outside FiveM's NUI browser, which has no handler for these
  // endpoints). Inside a real game client every one of these calls succeeds
  // and this fallback never triggers.
  const MOCK_RESPONSES = {
    placeSupplyOrder: () => mockState(),
    acceptContract: () => mockState(),
    abandonContract: () => mockState(),
    fulfillContract: () => mockState(),
  };

  function mockState() {
    return {
      reputation: { globe_oil: 32, kraken: 10, meridian: 0, blackgold: 0 },
      unlocked: { globe_oil: true, kraken: true, meridian: true, blackgold: true },
      contracts: [
        { playerContractId: 1, companyId: 'globe_oil', contractId: 'globe_intro_supply', progress: 3, heldCount: 3, status: 'active' },
      ],
      supplyOrders: [
        { id: 1, companyId: 'globe_oil', item: 'oil_bucket', quantity: 10, dropoffHq: 'globe_oil', readyAt: Math.floor(Date.now() / 1000) + 120, status: 'pending' },
      ],
    };
  }

  async function post(endpoint, data) {
    try {
      const resp = await fetch(`https://${resourceName}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {}),
      });
      return await resp.json();
    } catch (e) {
      const mock = MOCK_RESPONSES[endpoint];
      return mock ? mock() : {};
    }
  }

  function esc(str) {
    const div = document.createElement('div');
    div.textContent = str === undefined || str === null ? '' : String(str);
    return div.innerHTML;
  }

  function money(n) {
    return '$' + Math.max(0, Math.floor(n || 0)).toLocaleString('en-US');
  }

  function clamp(n, min, max) {
    return Math.min(max, Math.max(min, n));
  }

  function fmtClock(totalSeconds) {
    totalSeconds = Math.max(0, Math.floor(totalSeconds));
    const m = Math.floor(totalSeconds / 60);
    const s = totalSeconds % 60;
    return `${m}:${String(s).padStart(2, '0')}`;
  }

  // ============================================================
  // Notifications
  // ============================================================
  function showToast(payload) {
    const container = document.getElementById('notify-container');
    const toast = document.createElement('div');
    toast.className = `toast ${esc(payload.type || 'inform')}`;
    toast.innerHTML = `
      <div class="toast-title">${esc(payload.title || 'Globe Oil')}</div>
      <div class="toast-desc">${esc(payload.description || '')}</div>
    `;
    container.appendChild(toast);

    const duration = payload.duration || 5000;
    setTimeout(() => {
      toast.classList.add('leaving');
      setTimeout(() => toast.remove(), 200);
    }, duration);
  }

  // ============================================================
  // Text hint
  // ============================================================
  function textUIShow(payload) {
    document.getElementById('text-ui-label').textContent = payload.label || 'Interact';
    document.getElementById('text-ui').classList.remove('hidden');
  }

  function textUIHide() {
    document.getElementById('text-ui').classList.add('hidden');
  }

  // ============================================================
  // Progress bar
  // ============================================================
  let progressRAF = null;

  function progressStart(payload) {
    const container = document.getElementById('progress-container');
    const fill = document.getElementById('progress-fill');
    document.getElementById('progress-label').textContent = payload.label || '';
    fill.style.width = '0%';
    container.classList.remove('hidden');

    const duration = payload.duration || 1000;
    const start = performance.now();

    function tick(now) {
      const pct = clamp((now - start) / duration, 0, 1) * 100;
      fill.style.width = pct + '%';
      if (pct < 100) {
        progressRAF = requestAnimationFrame(tick);
      }
    }

    if (progressRAF) cancelAnimationFrame(progressRAF);
    progressRAF = requestAnimationFrame(tick);
  }

  function progressEnd() {
    if (progressRAF) cancelAnimationFrame(progressRAF);
    document.getElementById('progress-container').classList.add('hidden');
  }

  // ============================================================
  // Circular countdown HUD
  // ============================================================
  const CIRC = 2 * Math.PI * 45;
  let countdownTotal = 0;

  function countdownShow(payload) {
    document.getElementById('countdown-label').textContent = payload.label || 'Timer';
    countdownTotal = payload.seconds || 0;
    document.getElementById('countdown-fill').style.strokeDasharray = CIRC;
    countdownRender(payload.seconds || 0);
    document.getElementById('countdown-hud').classList.remove('hidden');
  }

  function countdownRender(seconds) {
    document.getElementById('countdown-text').textContent = fmtClock(seconds);
    const ratio = countdownTotal > 0 ? clamp(seconds / countdownTotal, 0, 1) : 0;
    document.getElementById('countdown-fill').style.strokeDashoffset = CIRC * (1 - ratio);
  }

  function countdownUpdate(payload) {
    countdownRender(payload.seconds || 0);
  }

  function countdownHide() {
    document.getElementById('countdown-hud').classList.add('hidden');
  }

  // ============================================================
  // Context menu
  // ============================================================
  function contextOpen(payload) {
    document.getElementById('context-title').textContent = payload.title || '';
    const list = document.getElementById('context-options');
    list.innerHTML = '';

    (payload.options || []).forEach((opt) => {
      const el = document.createElement('div');
      el.className = 'context-option';
      el.innerHTML = `
        <div class="co-title">${esc(opt.title)}</div>
        ${opt.description ? `<div class="co-desc">${esc(opt.description)}</div>` : ''}
      `;
      el.addEventListener('click', () => {
        post('contextSelect', { index: opt.index });
        document.getElementById('context-menu').classList.add('hidden');
      });
      list.appendChild(el);
    });

    document.getElementById('context-menu').classList.remove('hidden');
  }

  function contextClose() {
    post('contextClose', {});
    document.getElementById('context-menu').classList.add('hidden');
  }

  // ============================================================
  // Input modal
  // ============================================================
  let inputFieldDefs = [];

  function inputOpen(payload) {
    document.getElementById('input-title').textContent = payload.title || '';
    inputFieldDefs = payload.fields || [];
    const body = document.getElementById('input-fields');
    body.innerHTML = '';

    inputFieldDefs.forEach((field, i) => {
      const wrap = document.createElement('div');
      wrap.className = 'field';

      let inputEl;
      if (field.type === 'select') {
        inputEl = `<select id="input-field-${i}">${(field.options || []).map((o) => `<option value="${esc(o.value)}">${esc(o.label)}</option>`).join('')}</select>`;
      } else {
        inputEl = `<input id="input-field-${i}" type="${field.type === 'number' ? 'number' : 'text'}" value="${esc(field.default !== undefined ? field.default : '')}" min="${field.min !== undefined ? field.min : ''}" max="${field.max !== undefined ? field.max : ''}" />`;
      }

      wrap.innerHTML = `
        <label>${esc(field.label || '')}</label>
        ${inputEl}
        ${field.description ? `<div class="field-desc">${esc(field.description)}</div>` : ''}
      `;
      body.appendChild(wrap);
    });

    document.getElementById('input-modal').classList.remove('hidden');
  }

  function inputSubmit() {
    const values = inputFieldDefs.map((field, i) => {
      const el = document.getElementById(`input-field-${i}`);
      if (!el) return null;
      return field.type === 'number' ? Number(el.value) : el.value;
    });
    post('inputSubmit', { values });
    document.getElementById('input-modal').classList.add('hidden');
  }

  function inputCancel() {
    post('inputCancel', {});
    document.getElementById('input-modal').classList.add('hidden');
  }

  // ============================================================
  // Terminal
  // ============================================================
  const terminal = {
    static: null,   // companies / companyOrder / hqs / unlockThreshold / maxReputation
    state: null,    // reputation / unlocked / contracts / supplyOrders
    activeTab: 'dashboard',
    selectedSupplyCompany: null,
    selectedContractCompany: null,
  };

  function terminalOpen(payload) {
    terminal.static = payload || {};
    terminal.selectedSupplyCompany = (payload.companyOrder || [])[0] || null;
    terminal.selectedContractCompany = (payload.companyOrder || [])[0] || null;
    document.getElementById('terminal').classList.remove('hidden');
    switchTab(terminal.activeTab);
  }

  function terminalState(state) {
    terminal.state = state || {};
    renderActiveTab();
  }

  function terminalClose() {
    document.getElementById('terminal').classList.add('hidden');
  }

  function applyStateAndRerender(state) {
    terminal.state = state || terminal.state;
    renderActiveTab();
  }

  function switchTab(tab) {
    terminal.activeTab = tab;
    document.querySelectorAll('.tab-btn').forEach((btn) => btn.classList.toggle('active', btn.dataset.tab === tab));
    document.querySelectorAll('.tab-content').forEach((el) => el.classList.toggle('active', el.id === `tab-${tab}`));
    renderActiveTab();
  }

  function renderActiveTab() {
    if (!terminal.static || !terminal.state) return;
    if (terminal.activeTab === 'dashboard') renderDashboard();
    else if (terminal.activeTab === 'supplies') renderSupplies();
    else if (terminal.activeTab === 'contracts') renderContracts();
    else if (terminal.activeTab === 'reputation') renderReputation();
  }

  function companyLabel(id) {
    const c = terminal.static.companies[id];
    return c ? c.label : id;
  }

  function isUnlocked(id) {
    const c = terminal.static.companies[id];
    if (c && c.alwaysUnlocked) return true;
    return !!(terminal.state.unlocked || {})[id];
  }

  function perkTierFor(company, reputation) {
    let best = null;
    (company.perkTiers || []).forEach((tier) => {
      if (reputation >= tier.threshold) best = tier;
    });
    return best;
  }

  function nextTierFor(company, reputation) {
    return (company.perkTiers || []).find((tier) => reputation < tier.threshold) || null;
  }

  function perkSummary(company, tier) {
    if (!tier) return 'No perk active yet';
    if (company.perkType === 'drilling') return `-${Math.round((1 - tier.drillTimeMultiplier) * 100)}% drill time, +${Math.round((tier.bonusCrudeChance || 0) * 100)}% bonus crude chance`;
    if (company.perkType === 'refining') return `-${Math.round((1 - tier.refineTimeMultiplier) * 100)}% refine time, +${Math.round((tier.pureChanceBonus || 0) * 100)}% pure-quality chance`;
    if (company.perkType === 'commerce') return `+${Math.round((tier.sellPriceMultiplier - 1) * 100)}% sell price, +${Math.round((tier.contractReputationMultiplier - 1) * 100)}% contract reputation`;
    return '';
  }

  function renderDashboard() {
    const order = terminal.static.companyOrder || [];
    const rep = terminal.state.reputation || {};
    const maxRep = terminal.static.maxReputation || 100;

    const repCards = order.map((id) => {
      const company = terminal.static.companies[id];
      const value = rep[id] || 0;
      const unlocked = isUnlocked(id);
      return `
        <div class="card">
          <div class="card-title">
            <span>${esc(company.label)}</span>
            ${unlocked ? '' : '<span class="badge locked">Locked</span>'}
          </div>
          <div class="rep-bar-track"><div class="rep-bar-fill" style="width:${clamp((value / maxRep) * 100, 0, 100)}%"></div></div>
          <div class="rep-meta"><span>${value}/${maxRep} reputation</span></div>
        </div>
      `;
    }).join('');

    const orders = (terminal.state.supplyOrders || []).filter((o) => o.status !== 'collected');
    const ordersHtml = orders.length ? orders.map((o) => {
      const remaining = o.readyAt - Math.floor(Date.now() / 1000);
      const statusText = o.status === 'ready' || remaining <= 0 ? 'Ready for pickup' : `In transit - ${fmtClock(remaining)} remaining`;
      return `
        <div class="list-item">
          <div class="list-item-main">
            <div class="list-item-title">${esc(o.quantity)}x ${esc(Config_ItemLabel(o.item))}</div>
            <div class="list-item-desc">Drop-off: ${esc(terminal.static.hqs[o.dropoffHq] ? terminal.static.hqs[o.dropoffHq].label : o.dropoffHq)}</div>
          </div>
          <div class="list-item-desc">${esc(statusText)}</div>
        </div>
      `;
    }).join('') : '<div class="empty-state">No active supply orders.</div>';

    const contracts = (terminal.state.contracts || []).filter((c) => c.status === 'active');
    const contractsHtml = contracts.length ? contracts.map((c) => {
      const template = findContractTemplate(c.companyId, c.contractId);
      return `
        <div class="list-item">
          <div class="list-item-main">
            <div class="list-item-title">${esc(template ? template.title : c.contractId)}</div>
            <div class="list-item-desc">${esc(companyLabel(c.companyId))}</div>
          </div>
          <div class="list-item-desc">${esc(c.heldCount || 0)}/${esc(template ? template.quantity : '?')}</div>
        </div>
      `;
    }).join('') : '<div class="empty-state">No active contracts.</div>';

    document.getElementById('tab-dashboard').innerHTML = `
      <h1 class="tab-title">Dashboard</h1>
      <p class="tab-subtitle">Company standing, supply orders, and contracts at a glance.</p>
      <div class="card-grid">${repCards}</div>
      <h2 style="font-size:14px;margin:20px 0 8px;">Active Supply Orders</h2>
      ${ordersHtml}
      <h2 style="font-size:14px;margin:20px 0 8px;">Active Contracts</h2>
      ${contractsHtml}
    `;
  }

  function findContractTemplate(companyId, contractId) {
    const company = terminal.static.companies[companyId];
    if (!company) return null;
    return (company.contracts || []).find((c) => c.id === contractId) || null;
  }

  function Config_ItemLabel(item) {
    return (terminal.static.itemLabels && terminal.static.itemLabels[item]) || item;
  }

  function renderCompanyChips(selectedId, onSelect) {
    const order = terminal.static.companyOrder || [];
    return `<div class="select-row">${order.map((id) => {
      const unlocked = isUnlocked(id);
      const cls = ['select-chip'];
      if (id === selectedId) cls.push('active');
      if (!unlocked) cls.push('disabled');
      return `<button class="${cls.join(' ')}" data-company="${esc(id)}" ${unlocked ? '' : 'disabled'}>${esc(companyLabel(id))}${unlocked ? '' : ' (Locked)'}</button>`;
    }).join('')}</div>`;
  }

  function renderSupplies() {
    const selected = terminal.selectedSupplyCompany;
    const company = terminal.static.companies[selected];

    const catalogHtml = (company.catalog || []).map((entry, i) => `
      <div class="list-item">
        <div class="list-item-main">
          <div class="list-item-title">${esc(entry.label)}</div>
          <div class="list-item-desc">${money(entry.price)} each - ~${Math.round(entry.deliverySeconds / 60)} min delivery</div>
        </div>
        <button class="btn primary" data-order-index="${i}">Order</button>
      </div>
    `).join('');

    document.getElementById('tab-supplies').innerHTML = `
      <h1 class="tab-title">Supplies</h1>
      <p class="tab-subtitle">Order equipment from any company you've unlocked. Orders take time and are picked up at that company's HQ.</p>
      ${renderCompanyChips(selected, 'supply')}
      ${catalogHtml || '<div class="empty-state">This company has nothing in stock.</div>'}
    `;

    document.querySelectorAll('#tab-supplies [data-order-index]').forEach((btn) => {
      btn.addEventListener('click', () => openOrderModal(company, Number(btn.dataset.orderIndex)));
    });
  }

  function openOrderModal(company, catalogIndex) {
    const entry = company.catalog[catalogIndex];
    const hqOptions = (terminal.static.companyOrder || [])
      .filter((id) => isUnlocked(id))
      .map((id) => ({ value: id, label: terminal.static.hqs[id] ? terminal.static.hqs[id].label : id }));

    document.getElementById('input-title').textContent = `Order ${entry.label}`;
    inputFieldDefs = [
      { type: 'number', label: 'Quantity', description: `${money(entry.price)} each`, default: 1, min: 1, max: 50 },
      { type: 'select', label: 'Drop-off Location', options: hqOptions },
    ];
    const body = document.getElementById('input-fields');
    body.innerHTML = '';
    inputFieldDefs.forEach((field, i) => {
      const wrap = document.createElement('div');
      wrap.className = 'field';
      let inputEl;
      if (field.type === 'select') {
        inputEl = `<select id="input-field-${i}">${field.options.map((o) => `<option value="${esc(o.value)}">${esc(o.label)}</option>`).join('')}</select>`;
      } else {
        inputEl = `<input id="input-field-${i}" type="number" value="${field.default}" min="${field.min}" max="${field.max}" />`;
      }
      wrap.innerHTML = `<label>${esc(field.label)}</label>${inputEl}${field.description ? `<div class="field-desc">${esc(field.description)}</div>` : ''}`;
      body.appendChild(wrap);
    });

    document.getElementById('input-modal').classList.remove('hidden');

    document.getElementById('input-submit').onclick = async () => {
      const quantity = Number(document.getElementById('input-field-0').value) || 1;
      const dropoffHq = document.getElementById('input-field-1').value;
      document.getElementById('input-modal').classList.add('hidden');
      const result = await post('placeSupplyOrder', { companyId: company.id, item: entry.item, quantity, dropoffHq });
      applyStateAndRerender(result);
    };
    document.getElementById('input-cancel').onclick = () => {
      document.getElementById('input-modal').classList.add('hidden');
      resetInputButtons();
    };
  }

  function resetInputButtons() {
    document.getElementById('input-submit').onclick = inputSubmit;
    document.getElementById('input-cancel').onclick = inputCancel;
  }

  function renderContracts() {
    const selected = terminal.selectedContractCompany;
    const company = terminal.static.companies[selected];
    const activeForCompany = (terminal.state.contracts || []).filter((c) => c.companyId === selected && c.status === 'active');
    const activeIds = activeForCompany.map((c) => c.contractId);

    const availableHtml = (company.contracts || [])
      .filter((c) => activeIds.indexOf(c.id) === -1)
      .map((c) => `
        <div class="list-item">
          <div class="list-item-main">
            <div class="list-item-title">${esc(c.title)} <span class="badge ${esc(c.riskTier)}">${esc(c.riskTier)}</span></div>
            <div class="list-item-desc">${esc(c.description)}</div>
            <div class="list-item-desc">${esc(c.quantity)}x ${esc(Config_ItemLabel(c.item))} -> ${money(c.rewardCash)} + ${c.rewardReputation} reputation</div>
          </div>
          <button class="btn primary" data-accept="${esc(c.id)}">Accept</button>
        </div>
      `).join('');

    const activeHtml = activeForCompany.map((c) => {
      const template = findContractTemplate(c.companyId, c.contractId);
      const held = c.heldCount || 0;
      const canFulfill = template && held >= template.quantity;
      return `
        <div class="list-item">
          <div class="list-item-main">
            <div class="list-item-title">${esc(template ? template.title : c.contractId)}</div>
            <div class="list-item-desc">${esc(held)}/${esc(template ? template.quantity : '?')} ${esc(Config_ItemLabel(template ? template.item : ''))} held</div>
          </div>
          <div style="display:flex; gap:6px;">
            <button class="btn ghost" data-abandon="${esc(c.playerContractId)}">Abandon</button>
            <button class="btn primary" data-fulfill="${esc(c.playerContractId)}" ${canFulfill ? '' : 'disabled'}>Fulfill</button>
          </div>
        </div>
      `;
    }).join('');

    document.getElementById('tab-contracts').innerHTML = `
      <h1 class="tab-title">Contracts</h1>
      <p class="tab-subtitle">Accept up to ${terminal.static.maxActiveContractsPerCompany || 2} active contracts per company.</p>
      ${renderCompanyChips(selected, 'contract')}
      <h2 style="font-size:14px;margin:14px 0 8px;">Active</h2>
      ${activeHtml || '<div class="empty-state">No active contracts with this company.</div>'}
      <h2 style="font-size:14px;margin:20px 0 8px;">Available</h2>
      ${availableHtml || '<div class="empty-state">Nothing available right now.</div>'}
    `;

    document.querySelectorAll('#tab-contracts [data-accept]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const result = await post('acceptContract', { companyId: selected, contractId: btn.dataset.accept });
        applyStateAndRerender(result);
      });
    });
    document.querySelectorAll('#tab-contracts [data-abandon]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const result = await post('abandonContract', { playerContractId: Number(btn.dataset.abandon) });
        applyStateAndRerender(result);
      });
    });
    document.querySelectorAll('#tab-contracts [data-fulfill]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        const result = await post('fulfillContract', { playerContractId: Number(btn.dataset.fulfill) });
        applyStateAndRerender(result);
      });
    });
  }

  function renderReputation() {
    const order = terminal.static.companyOrder || [];
    const rep = terminal.state.reputation || {};
    const maxRep = terminal.static.maxReputation || 100;
    const unlockThreshold = terminal.static.unlockThreshold || 25;

    const cards = order.map((id) => {
      const company = terminal.static.companies[id];
      const value = rep[id] || 0;
      const unlocked = isUnlocked(id);
      const tier = perkTierFor(company, value);
      const next = nextTierFor(company, value);

      let unlockNote = '';
      if (id === 'globe_oil') {
        const pct = clamp((value / unlockThreshold) * 100, 0, 100);
        unlockNote = value >= unlockThreshold
          ? '<div class="list-item-progress">All other companies unlocked.</div>'
          : `<div class="rep-bar-track" style="margin-top:10px;"><div class="rep-bar-fill" style="width:${pct}%"></div></div><div class="rep-meta"><span>${value}/${unlockThreshold} to unlock Kraken, Meridian &amp; Blackgold</span></div>`;
      }

      return `
        <div class="card" style="grid-column: span 2;">
          <div class="card-title">
            <span>${esc(company.label)}</span>
            ${unlocked ? '' : '<span class="badge locked">Locked</span>'}
          </div>
          <div class="rep-bar-track"><div class="rep-bar-fill" style="width:${clamp((value / maxRep) * 100, 0, 100)}%"></div></div>
          <div class="rep-meta"><span>${value}/${maxRep} reputation</span></div>
          <div class="list-item-desc" style="margin-top:8px;">${esc(perkSummary(company, tier))}</div>
          ${next ? `<div class="list-item-desc">Next perk tier at ${next.threshold} reputation</div>` : ''}
          ${unlockNote}
        </div>
      `;
    }).join('');

    document.getElementById('tab-reputation').innerHTML = `
      <h1 class="tab-title">Reputation</h1>
      <p class="tab-subtitle">Perks apply automatically whenever you interact with that company - no need to pick one as an "employer."</p>
      <div class="card-grid">${cards}</div>
    `;
  }

  // ============================================================
  // Wiring
  // ============================================================
  window.addEventListener('message', (event) => {
    const { action, payload } = event.data || {};
    switch (action) {
      case 'notify': showToast(payload); break;
      case 'textUIShow': textUIShow(payload); break;
      case 'textUIHide': textUIHide(); break;
      case 'progressStart': progressStart(payload); break;
      case 'progressEnd': progressEnd(); break;
      case 'countdownShow': countdownShow(payload); break;
      case 'countdownUpdate': countdownUpdate(payload); break;
      case 'countdownHide': countdownHide(); break;
      case 'contextOpen': contextOpen(payload); break;
      case 'inputOpen': resetInputButtons(); inputOpen(payload); break;
      case 'terminalOpen': terminalOpen(payload); break;
      case 'terminalState': terminalState(payload); break;
      case 'terminalClose': terminalClose(); break;
      case 'closeAll':
        textUIHide(); progressEnd(); countdownHide();
        document.getElementById('context-menu').classList.add('hidden');
        document.getElementById('input-modal').classList.add('hidden');
        terminalClose();
        break;
      default: break;
    }
  });

  document.addEventListener('DOMContentLoaded', () => {
    resetInputButtons();

    document.querySelectorAll('[data-close="context"]').forEach((el) => el.addEventListener('click', contextClose));
    document.querySelectorAll('[data-close="input"]').forEach((el) => el.addEventListener('click', () => {
      document.getElementById('input-modal').classList.add('hidden');
      inputCancel();
    }));
    document.querySelectorAll('[data-close="terminal"]').forEach((el) => el.addEventListener('click', () => {
      terminalClose();
      post('terminalClose', {});
    }));

    document.querySelectorAll('.tab-btn').forEach((btn) => btn.addEventListener('click', () => switchTab(btn.dataset.tab)));

    document.body.addEventListener('click', (e) => {
      const chip = e.target.closest('.select-chip');
      if (!chip || chip.disabled) return;
      const companyId = chip.dataset.company;
      if (!companyId) return;

      if (chip.closest('#tab-supplies')) {
        terminal.selectedSupplyCompany = companyId;
        renderSupplies();
      } else if (chip.closest('#tab-contracts')) {
        terminal.selectedContractCompany = companyId;
        renderContracts();
      }
    });

    document.addEventListener('keydown', (e) => {
      if (e.key !== 'Escape') return;
      if (!document.getElementById('terminal').classList.contains('hidden')) {
        terminalClose();
        post('terminalClose', {});
      } else if (!document.getElementById('context-menu').classList.contains('hidden')) {
        contextClose();
      } else if (!document.getElementById('input-modal').classList.contains('hidden')) {
        document.getElementById('input-modal').classList.add('hidden');
        inputCancel();
      }
    });
  });
})();
