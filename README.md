# OrpheusHook

## Still work in progress and docker is not built yet

OrpheusHook is a webhook companion service for [autobrr](https://github.com/autobrr/autobrr) designed to check the names of uploaders, your ratio, and record labels associated with torrents on Orpheus. It provides a simple and efficient way to validate if uploaders are blacklisted or whitelisted, to stop racing in case your ratio falls below a certain point, and to verify if a torrent's record label matches against a specified list.

## Features

- Verify if an uploader's name is on a provided whitelist or blacklist.
- Check for record labels. Useful for grabbing torrents from a specific label.
- Check if a user's ratio meets a specified minimum value (additional API hit if used with the other two).
- Check the torrentSize (Useful for not hitting the API from both autobrr and orpheushook)
- Easy to integrate with other applications via webhook.
- Rate Limiter set to a maximum of 10 requests per 10 seconds to abide by RED rules.

It was made with [autobrr](https://github.com/autobrr/autobrr) in mind.

## Getting Started

### Warning

Remember that autobrr also checks the RED API if you have min/max sizes set. This will result in you hitting the API 2x.
So for your own good, don't set size checks in your autobrr filter is you use OrpheusHook.

### Prerequisites

To run OrpheusHook, you'll need:

1. Go 1.20 or later installed **(if building from source)**
2. Access to Orpheus

### Installation

#### Docker

```bash
docker pull ghcr.io/locke69321/orpheushook:latest
```

**docker compose**

```docker
version: "3.7"
services:
  orpheushook:
    container_name: orpheushook
    image: ghcr.io/locke69321/orpheushook:latest
    user: 1000:1000
    environment:
      - SERVER_ADDRESS=0.0.0.0 # binds to 127.0.0.1 by default
      - SERVER_PORT=42135 # defaults to 42135
    ports:
      - "42135:42135"
```

#### Using precompiled binaries

Download the appropriate binary for your platform from the [releases](https://github.com/locke69321/OrpheusHook/releases/latest) page.

#### Building from source

1. Clone the repository:

```bash
git clone https://github.com/locke69321/OrpheusHook.git
```

2. Navigate to the project directory:

```bash
cd OrpheusHook
```
3. Build the project:

```go
go build
```
or
```shell
make build
```

4. Run the compiled binary:

```bash
./bin/OrpheusHook
```

## Usage

To use OrpheusHook, send POST requests to the following endpoint:

    Endpoint: http://127.0.0.1:42135/orpheus/hook
    Method: POST
    Expected HTTP Status: 200

You can check the ratio, uploader, size and record label in a single request or separately. Keep in mind that checking the ratio will result in an additional API hit on the RED API, as it's not part of the same endpoint as uploaders and record labels.

**JSON Payload for everything:**

```json
{
  "user_id": USER_ID,
  "apikey": "API_KEY",
  "minratio": MINIMUM_RATIO,
  "torrent_id": {{.TorrentID}},
  "uploaders": "USER1,USER2,USER3",
  "mode": "blacklist/whitelist",
  "record_labels": "LABEL1,LABEL2,LABEL3"
}
```

**JSON Payload for ratio check:**

```json
{
  "user_id": USER_ID,
  "apikey": "API_KEY",
  "minratio": MINIMUM_RATIO
}
```

**JSON Payload for uploader and size check:**

```json
{
  "torrent_id": {{.TorrentID}},
  "apikey": "API_KEY",
  "uploaders": "USER1,USER2,USER3",
  "mode": "blacklist/whitelist",
  "maxsize": 340155737
}
```

**JSON Payload for record label check:**

```json
{
  "torrent_id": {{.TorrentID}},
  "apikey": "API_KEY",
  "record_labels": "LABEL1,LABEL2,LABEL3"
}
```

`user_id` is the number in the URL when you visit your profile.

`api_key` is your Orpheus API key. Needs user and torrents privileges.

`minsize` is the minimum allowed size **measured in bytes** you want to grab.

`maxsize` is the max allowed size **measured in bytes** you want to grab.

`uploaders` is a comma-separated list of uploaders to check against.

`mode` is either blacklist or whitelist. If blacklist is used, the torrent will be stopped if the uploader is found in the list. If whitelist is used, the torrent will be stopped if the uploader is not found in the list.

`record_labels` is a comma-separated list of record labels to check against.

#### curl commands for easy testing

```bash
curl -X POST -H "Content-Type: application/json" -d '{"user_id": 3855, "apikey": "e1be0c8f.6a1d6f89de6e9f6a61e6edcbb6a3a32d", "minratio": 1.0}' http://127.0.0.1:42135/orpheus/hook
```
```bash
curl -X POST -H "Content-Type: application/json" -d '{"torrent_id": 3931392, "apikey": "e1be0c8f.6a1d6f89de6e9f6a61e6edcbb6a3a32d", "mode": "blacklist", "uploaders": "blacklisted_user1,blacklisted_user2,blacklisted_user3"}' http://127.0.0.1:42135/orpheus/hook
```

```bash
curl -X POST -H "Content-Type: application/json" -d '{"torrent_id": 3931392, "apikey": "e1be0c8f.6a1d6f89de6e9f6a61e6edcbb6a3a32d", "maxsize": 340155737}' http://127.0.0.1:42135/orpheus/hook
```