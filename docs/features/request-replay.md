---
sidebar_label: 'Request Replay'
---

# Request Replay

One of the most powerful features of Alice is **Request Replay**.

When debugging a failing API call, fixing the backend issue (or adjusting a parameter) usually requires navigating all the way back through your app's UI to trigger the request again. 

Alice's Request Replay feature allows you to bypass this friction entirely.

## How it works

From the **Call Details** view of any previously logged HTTP request, you can simply tap the **Replay** button.

1. Alice will instantly reconstruct the exact request (including the original headers, query parameters, and body).
2. It will bypass any of your app's interceptors (to prevent double-logging or side effects).
3. It will execute the HTTP call directly from the inspector.
4. The new result will be added to your Calls List.

## Replay Indicators

To ensure you don't confuse original user-driven traffic with your manual replays, Alice visually marks replayed requests. Replayed calls feature a distinct **Replay indication badge** in the Calls List, so you can easily trace the history of your debugging session.
