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

### Interactive JSON Viewer

*Added in Alice 1.5.0*

When a request or response body contains JSON data, Alice automatically provides an **interactive tree-based JSON viewer**. 

Instead of reading through a massive, unformatted text string, you can collapse and expand JSON nodes, making it incredibly easy to navigate deeply nested API responses directly on your mobile device. If the payload is too large, you still have the option to view the raw text or copy it to your clipboard.
