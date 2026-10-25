---
sidebar_label: 'Inspector UI'
---

# Inspector UI

Alice provides a rich, on-device UI to inspect your HTTP traffic. 

## Calls List

The main screen of Alice is the Calls List. It displays a chronological list of all intercepted HTTP requests. 
Each item in the list provides a quick summary:
- HTTP Method (GET, POST, etc.)
- Status Code (with color coding: green for success, red for error)
- URL Endpoint
- Request Duration and Size
- Secured (HTTPS) or Unsecured (HTTP) indicator

You can tap on any call to view its detailed information.

## Call Details

The Call Details screen provides an in-depth look at a specific HTTP request and response. It is split into several tabs:

- **Overview**: High-level summary of the call (Server, Client, Duration, Bytes sent/received).
- **Request**: Headers, Query Parameters, and the Request Body.
- **Response**: Headers and the Response Body.
- **Error**: If the call failed due to a network error or exception, the stack trace and error message are shown here.

### Interactive JSON Viewer & Developer Tools

*Updated in Alice 2.0.0*

When a request or response body contains JSON data, Alice automatically provides an **interactive tree-based JSON viewer** with developer utilities:

- **Node Collapsing & Expanding**: Navigate complex, nested payloads easily without drowning in raw text strings.
- **Long-Press Node Actions**: Long-press on any JSON key or value to open a context menu:
  - **Copy Value**: Copies the node's primitive value (e.g. `'abc'`, `123`).
  - **Copy JSONPath**: Copies the exact selector path (e.g. `$.data.users[0].email`).
  - **Copy Subtree**: Copies the subtree starting from that node formatted as indented JSON.

### Interactive XML & SVG Viewer

*Added in Alice 1.11.0*

When a response body contains XML or SVG (`image/svg+xml`) payloads, Alice provides an **interactive tree-based XML viewer** mirroring the JSON viewer. 

You can collapse and expand XML elements, attributes, and text nodes cleanly without getting lost in raw XML strings.
