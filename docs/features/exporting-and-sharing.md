---
sidebar_label: 'Exporting & Sharing'
---

# Exporting & Sharing

Alice allows you to export your captured HTTP calls for offline sharing, team collaboration, or deeper analysis in specialized tools. You can trigger exports from the overflow menu in the Calls List or share individual calls from their specific details page.

## Export Formats

When exporting logs from Alice, you will be prompted with a dialog to choose your preferred format:

### 1. HAR (HTTP Archive 1.2)
*Added in Alice 1.6.0*

HAR is an industry-standard JSON-based format for logging web browser and network interaction. 
- **Best for**: Deep technical analysis.
- **Tools**: HAR files can be directly imported into tools like Google Chrome DevTools, Postman, Charles Proxy, or Insomnia. This allows backend engineers to replay and inspect the exact requests your mobile app made.

### 2. TXT (Plain Text)
A simple, human-readable text file containing the headers, bodies, and metadata of your calls.
- **Best for**: Quick sharing via email, Slack, or attaching to bug tickets (Jira, GitHub Issues) where a simple text overview is sufficient.

## Sharing 

When you export logs, Alice uses the native share sheet (`share_plus`) to let you send the file via email, Slack, AirDrop, etc. 

### Web Clipboard Fallback
*Added in Alice 1.6.0*

Because native file sharing behaves differently on web browsers, Alice includes a smart clipboard fallback for Flutter Web. If the browser does not support the native Web Share API, Alice will automatically copy the exported data (TXT or HAR JSON) directly to your clipboard so you can paste it where needed.

## Share cURL

In addition to full exports, you can easily share a specific request as a **cURL command**. 
From the Call Details screen, tap the Share FAB (Floating Action Button) or use the overflow menu to select "Share cURL". This generates a ready-to-run terminal command containing the exact URL, headers, and body of the request, which is incredibly useful for instantly reproducing a backend issue.
