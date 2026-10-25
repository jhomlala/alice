---
sidebar_label: 'Search & Filtering'
---

# Search & Filtering

Alice includes a search bar in the Inspector UI to quickly find specific HTTP calls among dozens of requests.

## Basic Search

Typing into the search bar performs a plain text search across request URLs and endpoints.

## Advanced Search Filters

Filter calls using dedicated syntax keys:

- `method:GET` (or `POST`, `PUT`, `DELETE`, etc.)
- `status:200` (or `404`, `500`, etc.)
- `host:google.com` or `server:google.com` (matches the server/host name)
- `client:dio` (matches the HTTP client: `dio`, `chopper`, `http`, `HttpClient`)
- `duration:>1000` (finds requests longer than 1000ms; supports `<`, `>`, and `=`)
- `tag:login-flow` (matches requests tagged with `alice.tag(tag: ...)`)
- `duplicate:true` (shows duplicate N+1 requests detected within the duplicate window)

### Combining Filters

Combine multiple filters separated by spaces. 

For example:
```text
status:500 method:POST api/users
```
Shows only failed POST requests to the `api/users` endpoint.

### Search Help

Tap the Help (?) icon next to the search bar in the app for a quick filter syntax reference.
