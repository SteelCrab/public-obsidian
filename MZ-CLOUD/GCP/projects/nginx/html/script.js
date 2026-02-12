const statusBadge = document.getElementById('statusBadge');
const apiResult = document.getElementById('apiResult');

async function checkHealth() {
    statusBadge.textContent = 'Checking...';
    statusBadge.className = 'badge';
    apiResult.textContent = '';

    try {
        const res = await fetch('/health');
        const data = await res.json();

        if (data.status === 'healthy') {
            statusBadge.textContent = 'Healthy';
            statusBadge.className = 'badge healthy';
        } else {
            statusBadge.textContent = 'Unhealthy';
            statusBadge.className = 'badge error';
        }

        const apiRes = await fetch('/api');
        const apiData = await apiRes.json();
        apiResult.textContent = apiData.message;

    } catch (error) {
        statusBadge.textContent = 'Error';
        statusBadge.className = 'badge error';
        apiResult.textContent = error.message;
    }
}

checkHealth();
