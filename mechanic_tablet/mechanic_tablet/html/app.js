const app = document.getElementById('app');
const feedback = document.getElementById('feedback');
const title = document.getElementById('title');
const meta = document.getElementById('meta');
const mechanicName = document.getElementById('mechanicName');
const closeBtn = document.getElementById('closeBtn');
const actionButtons = [...document.querySelectorAll('[data-action]')];
const vehicleData = document.getElementById('vehicleData');

const statsOrder = ['plate', 'model', 'engine', 'body', 'fuel', 'dirt'];

const state = {
  locale: {
    title: 'Mechanic Tablet',
    statusOnline: 'Online'
  }
};

function getNuiResourceName() {
  if (window.GetParentResourceName) {
    return window.GetParentResourceName();
  }
  return 'mechanic_tablet';
}

async function nui(action, data = {}) {
  const resourceName = getNuiResourceName();
  const response = await fetch(`https://${resourceName}/${action}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8'
    },
    body: JSON.stringify(data)
  });
  return response.json();
}

function setFeedback(message, isError = false) {
  feedback.textContent = message;
  feedback.style.color = isError ? '#ff9da9' : '#99daf9';
}

function renderVehicle(snapshot) {
  const values = {
    plate: snapshot?.plate ?? '-',
    model: snapshot?.model ?? '-',
    engine: snapshot?.engine ?? '-',
    body: snapshot?.body ?? '-',
    fuel: snapshot?.fuel ?? '-',
    dirt: snapshot?.dirt ?? '-'
  };

  const rows = vehicleData.querySelectorAll('li span');
  statsOrder.forEach((key, idx) => {
    rows[idx].textContent = values[key];
  });
}

function open(payload) {
  state.locale = payload.locale || state.locale;
  title.textContent = state.locale.title || 'Mechanic Tablet';
  meta.textContent = `Framework: ${payload.framework || 'open'}`;
  mechanicName.textContent = payload.mechanicName || 'Unknown';
  app.classList.remove('hidden');
  setFeedback('Ready.');
}

function close() {
  app.classList.add('hidden');
}

window.addEventListener('message', (event) => {
  const { action, payload } = event.data || {};
  if (action === 'open') {
    open(payload || {});
  }
  if (action === 'close') {
    close();
  }
});

closeBtn.addEventListener('click', async () => {
  await nui('close');
});

actionButtons.forEach((btn) => {
  btn.addEventListener('click', async () => {
    const action = btn.dataset.action;
    btn.disabled = true;
    setFeedback('Working...');

    try {
      const result = await nui(action);
      if (!result.ok) {
        setFeedback(result.message || 'Action failed', true);
      } else {
        if (result.data) {
          renderVehicle(result.data);
        }
        setFeedback(result.message || 'Done.');
      }
    } catch (error) {
      setFeedback('NUI request failed.', true);
    } finally {
      btn.disabled = false;
    }
  });
});

window.addEventListener('keydown', async (event) => {
  if (event.key === 'Escape') {
    await nui('close');
  }
});

nui('nuiReady').catch(() => {
  // Safe fallback for browser preview mode outside FiveM.
});
