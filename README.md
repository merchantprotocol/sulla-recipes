# sulla-recipes

The official plugin recipes registry for [Sulla Desktop](https://github.com/merchantprotocol/sulla-desktop).

Browse, install, and contribute extensions that extend Sulla's capabilities — container managers, smart home hubs, monitoring dashboards, and more.

---

## How It Works

Each plugin lives in its own folder under `recipes/`. The Sulla Desktop runtime fetches `index.yaml` for a fast summary of all available plugins, then loads individual `manifest.yaml` files on demand when a user installs or previews an extension.

---

## Repository Structure

```
sulla-recipes/
├── recipes/
│   ├── <plugin-name>/
│   │   ├── manifest.yaml   ← required
│   │   └── icon.png        ← optional (recommended: 256×256 PNG)
│   └── ...
├── index.yaml              ← auto-generated plugin index
└── README.md
```

---

## Manifest Schema

Every plugin requires a `manifest.yaml` inside its folder. Minimum required fields:

```yaml
name: portainer
displayName: "Portainer"
description: "Container management UI for Docker and Kubernetes"
version: "1.0.0"
author: "Jonathon Byrdziak"
category: "DevOps"          # DevOps | HomeAutomation | Monitoring | Productivity | Security | Other
icon: icon.png              # optional — relative path to icon file
homepage: "https://portainer.io"
tags:
  - docker
  - kubernetes
  - containers
install:
  type: docker-compose      # docker-compose | helm | script | url
  source: "https://..."     # URL or inline content
```

### Field Reference

| Field | Required | Description |
|-------|----------|-------------|
| `name` | ✅ | Unique kebab-case identifier (must match folder name) |
| `displayName` | ✅ | Human-readable plugin name shown in the UI |
| `description` | ✅ | Short one-line description (max 120 chars) |
| `version` | ✅ | Semantic version string (e.g. `1.0.0`) |
| `author` | ✅ | Plugin author name or GitHub handle |
| `category` | ✅ | One of the supported categories above |
| `icon` | ⬜ | Relative path to icon file (recommended: 256×256 PNG) |
| `homepage` | ⬜ | URL to the plugin's official homepage or docs |
| `tags` | ⬜ | List of searchable tags |
| `install.type` | ✅ | Installation method |
| `install.source` | ✅ | Source URL or reference for the install payload |

---

## Contributing a Recipe

1. Fork this repository
2. Create a new folder under `recipes/` using your plugin's kebab-case name
3. Add `manifest.yaml` (required) and `icon.png` (optional)
4. Open a Pull Request — CI will validate your manifest automatically
5. Once merged, your plugin appears in Sulla Desktop's extension browser

---

## Categories

| Category | Description |
|----------|-------------|
| `DevOps` | Containers, CI/CD, infrastructure tooling |
| `HomeAutomation` | Smart home platforms and integrations |
| `Monitoring` | Dashboards, alerting, observability |
| `Productivity` | Apps that make you faster |
| `Security` | Auth, secrets, network security tools |
| `Other` | Anything that doesn't fit above |

---

## License

MIT — contributions welcome.
