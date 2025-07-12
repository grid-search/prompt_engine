// Import the NProgress library for loading bars. It's a nice touch.
import NProgress from 'nprogress';

// Import the essential Phoenix LiveView client-side code.
import { Socket } from 'phoenix';
import { LiveSocket } from 'phoenix_live_view';

// Get the CSRF token from a meta tag in the HTML head.
// Phoenix embeds this for security.
const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute('content');

// Create the LiveSocket instance.
const liveSocket = new LiveSocket('/live', Socket, {
  params: { _csrf_token: csrfToken },
});

// Show a progress bar at the top of the page during page loads
// and LiveView events for better user feedback.
window.addEventListener('phx:page-loading-start', () => NProgress.start());
window.addEventListener('phx:page-loading-stop', () => NProgress.done());

// Connect the LiveSocket to the server.
liveSocket.connect();

// Expose the liveSocket instance for debugging purposes in the browser console.
window.liveSocket = liveSocket;
