---
sidebar_label: 'Search & Filtering'
---

# Search & Filtering

Alice features a powerful search bar in the Inspector UI to help you quickly find specific HTTP calls, especially useful when your app makes dozens of requests during a single session.

## Basic Search

By default, typing into the search bar will perform a plain text search against the request URLs and endpoints.

## Advanced Search Filters

*Added in Alice 1.6.0*

For pinpoint precision, you can use Alice's advanced syntax filters. These allow you to filter based on specific attributes of the HTTP call:

- `method:GET` (or `POST`, `PUT`, `DELETE`, etc.)
- `status:200` (or `404`, `500`, etc.)
- `host:google.com` (matches the server/host name)
- `client:dio` (matches the HTTP client used, e.g., `dio`, `chopper`, `http`)
- `duration:>1000` (finds requests that took longer than 1000ms. Supports `<`, `>`, and `=`)

### Combining Filters

You can combine multiple filters in a single search query separated by spaces. 

For example, typing:
```text
status:500 method:POST api/users
```
Will filter the list to show **only failed POST requests** to the `api/users` endpoint.

### Search Help

If you forget the syntax, you can always tap the Help (?) icon next to the search bar in the app to view a quick reference dialog explaining the advanced filter syntax.
