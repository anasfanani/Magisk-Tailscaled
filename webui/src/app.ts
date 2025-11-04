// Detect environment
const isAndroidApp = typeof (window as any).Android !== 'undefined';

console.log('[DEBUG] Environment:', isAndroidApp ? 'Android APK' : 'KSUWebUI');

// Unified exec function
async function exec(command: string): Promise<string> {
  console.log('[DEBUG] Executing:', command);
  
  if (isAndroidApp) {
    // Running in Android APK
    try {
      const result = (window as any).Android.exec(command);
      console.debug('[DEBUG] Result:', result);
      return result;
    } catch (e) {
      console.error('[DEBUG] Error:', e);
      return JSON.stringify({ error: String(e) });
    }
  } else {
    // Running in KSUWebUI
    try {
      const { exec } = await import('kernelsu');
      const { stdout } = await exec(command);
      console.debug('[DEBUG] Result:', stdout);
      return stdout;
    } catch (e) {
      console.error('[DEBUG] KernelSU error:', e);
      return JSON.stringify({ error: 'KernelSU not available' });
    }
  }
}

// Check if module is installed
async function checkModule(): Promise<boolean> {
  console.log('[DEBUG] Checking module...');
  
  if (isAndroidApp) {
    const result = (window as any).Android.isModuleInstalled();
    console.log('[DEBUG] Module installed:', result);
    return result;
  }
  return true; // Assume installed in KSUWebUI
}

// Get Tailscale status
async function getStatus() {
  console.log('[DEBUG] Getting status...');
  try {
    const output = await exec('tailscale status --json || echo "{}"');
    const parsed = JSON.parse(output);
    console.log('[DEBUG] Status:', parsed);
    return parsed;
  } catch (e) {
    console.error('[DEBUG] Status error:', e);
    return { error: 'Failed to get status' };
  }
}

// Get Tailscale IP
async function getIP() {
  console.log('[DEBUG] Getting IP...');
  const output = await exec('tailscale ip -4');
  console.log('[DEBUG] IP:', output.trim());
  return output.trim();
}

// Tailscale up
async function tailscaleUp() {
  console.log('[DEBUG] Tailscale up...');
  return await exec('tailscale up');
}

// Tailscale down
async function tailscaleDown() {
  console.log('[DEBUG] Tailscale down...');
  return await exec('tailscale down');
}

// Initialize UI
async function init() {
  console.log('[DEBUG] Initializing UI...');
  
  const statusEl = document.getElementById('status');
  const ipEl = document.getElementById('ip');
  const upBtn = document.getElementById('up-btn');
  const downBtn = document.getElementById('down-btn');

  if (!statusEl || !ipEl) {
    console.error('[DEBUG] Required elements not found!');
    return;
  }

  // Check module
  const moduleInstalled = await checkModule();
  if (!moduleInstalled) {
    statusEl.textContent = 'Module not installed!';
    console.error('[DEBUG] Module not installed');
    return;
  }

  // Update status
  async function updateStatus() {
    console.log('[DEBUG] Updating status...');
    try {
      const status = await getStatus();
      const ip = await getIP();

      if (!statusEl || !ipEl) return;

      if (status.BackendState === 'Running') {
        statusEl.textContent = '✓ Connected';
        statusEl.style.color = '#4ade80';
      } else {
        statusEl.textContent = '✗ Disconnected';
        statusEl.style.color = '#f87171';
      }

      ipEl.textContent = ip || 'No IP';
      console.log('[DEBUG] Status updated successfully');
    } catch (e) {
      console.error('[DEBUG] Update status error:', e);
      if (statusEl) statusEl.textContent = 'Error: ' + String(e);
    }
  }

  // Button handlers
  upBtn?.addEventListener('click', async () => {
    console.log('[DEBUG] Up button clicked');
    await tailscaleUp();
    setTimeout(updateStatus, 1000);
  });

  downBtn?.addEventListener('click', async () => {
    console.log('[DEBUG] Down button clicked');
    await tailscaleDown();
    setTimeout(updateStatus, 1000);
  });

  // Initial update - non-blocking
  console.log('[DEBUG] Starting initial update...');
  updateStatus(); // No await - runs in background

  // Auto-refresh every 5 seconds
  setInterval(updateStatus, 5000);
}

// Start when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
