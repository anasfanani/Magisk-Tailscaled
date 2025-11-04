import { exec, toast } from 'kernelsu';

const $ = (id: string) => document.getElementById(id)!;

async function runCmd(cmd: string) {
  const result = await exec(cmd);
  return result;
}

async function updateStatus() {
  $('status').innerHTML = 'Loading...';
  $('info').innerHTML = '';

  // Check if service is running
  const serviceCheck = await runCmd('tailscaled.service status');
  const isRunning =
    serviceCheck.errno === 0 && serviceCheck.stdout.includes('running');

  if (!isRunning) {
    $('status').innerHTML = '<span class="status-offline">● Service Stopped</span>';
    $('info').innerHTML = 'Tailscaled service is not running';
    return;
  }

  // Get simple status
  const statusResult = await runCmd('tailscale status');

  if (statusResult.errno !== 0) {
    $('status').innerHTML = '<span class="status-offline">● Error</span>';
    $('info').innerHTML =
      'Failed to get status: ' + (statusResult.stderr || 'Unknown error');
    return;
  }

  const statusText = statusResult.stdout || '';
  const hasConnection =
    statusText.length > 10 && !statusText.includes('Logged out');

  if (hasConnection) {
    $('status').innerHTML = '<span class="status-online">● Connected</span>';
  } else {
    $('status').innerHTML = '<span class="status-offline">● Not logged in</span>';
  }

  // Get IP
  const ipResult = await runCmd('tailscale ip -4');
  const ip = ipResult.errno === 0 ? ipResult.stdout.trim() : 'N/A';

  // Get hostname
  const hostnameResult = await runCmd('hostname');
  const hostname =
    hostnameResult.errno === 0 ? hostnameResult.stdout.trim() : 'Unknown';

  let info = `<strong>Hostname:</strong> ${hostname}<br>`;
  info += `<strong>Tailscale IP:</strong> ${ip}<br>`;
  info += `<strong>Service:</strong> Running`;

  $('info').innerHTML = info;
}

async function getLogs() {
  const result = await runCmd(
    'tail -n 50 /data/adb/tailscale/run/tailscaled.log'
  );
  $('logs').textContent = result.stdout || 'No logs available';
}

$('btn-refresh').onclick = async () => {
  await updateStatus();
  await getLogs();
  toast('Refreshed');
};

$('btn-start').onclick = async () => {
  await runCmd('tailscaled.service start');
  toast('Starting service...');
  setTimeout(updateStatus, 2000);
};

$('btn-stop').onclick = async () => {
  await runCmd('tailscaled.service stop');
  toast('Stopping service...');
  setTimeout(updateStatus, 2000);
};

$('btn-login').onclick = async () => {
  const result = await runCmd('tailscale login');
  if (result.stdout) {
    $('logs').textContent = result.stdout;
    toast('Check logs for login URL');
  }
};

// Initial load
updateStatus();
getLogs();
