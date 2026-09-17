---
sidebar_label: 'Stats & Timeline'
---

# Stats & Timeline

Beyond looking at individual requests, Alice provides powerful tools to understand your app's overall network health and performance.

## Stats Dashboard

Alice includes a comprehensive Statistics screen that acts as a modern, actionable dashboard for your network traffic.

### Metrics Grid
At the top of the dashboard, a grid provides high-level metrics at a glance:
- **Total Calls**: The total number of HTTP requests recorded.
- **Avg Time**: The average duration of all completed requests.
- **Data Transferred**: Total bytes sent and received.
- **Pending**: Requests currently in-flight.

### Visual Ratio Bars
To help you quickly identify issues, the dashboard includes visual distribution bars:
- **Status Codes**: See the ratio of 2xx (Success), 4xx (Client Error), and 5xx (Server Error) responses.
- **HTTP Methods**: See the breakdown of GET, POST, PUT, DELETE, etc. requests.

### Actionable Insights
Instead of just showing numbers, the Stats dashboard highlights critical calls that might need your attention:
- **Top 3 Slowest**: The requests that took the longest to complete.
- **Recent Errors**: The most recent calls that failed or returned error status codes.
- **Largest Payloads**: Requests or responses that consumed the most bandwidth.

You can tap directly on any of these actionable insights to navigate straight to the Call Details view for that specific request.

---

## Timeline (Gantt Chart)

When debugging complex screens that make multiple parallel or sequential API requests, understanding the *timing* of those requests is crucial.

Alice features an interactive **Gantt chart Timeline tab**. This visualizes your HTTP calls over time, allowing you to easily spot:
- **Waterfalls**: Requests that are unnecessarily waiting for previous requests to finish before starting.
- **Bottlenecks**: Extremely slow requests blocking the rest of the flow.
- **Parallelism**: Ensuring requests that can run concurrently are actually doing so.
