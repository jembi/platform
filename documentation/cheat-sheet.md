---
description: This page gives a list of common command and examples for easy reference
---

# 🗒️ Cheat sheet

#### Install the latest Instant OpenHIE binary locally:

```bash
sudo curl -L https://github.com/openhie/instant-v2/releases/latest/download/instant-linux -o /usr/local/bin/instant
```

#### Launch a particular package (with metadata initialisation):

```bash
instant package init -n <package_name>
```

#### Stop a particular package:

```bash
instant package down -n <package_name>
```

#### Start a particular package (WITHOUT metadata initialisation):

```bash
instant package up -n <package_name>
```

#### Destroy (delete all data too) a particular package:

```bash
instant package destroy -n <package_name>
```

#### Launch a particular recipe (with metadata initialisation) using profiles (which are defined in the config.yaml file):

```bash
instant package init -p <profile_name>
```

#### Stop a particular recipe:

```bash
instant package down -p <profile_name>
```

#### Start a particular recipe (WITHOUT metadata initialisation):

```bash
instant package up -p <profile_nameage_name>
```

#### Destroy (delete all data too) a particular recipe:

```bash
instant package destroy -p <profile_name>
```

#### Add --dev to any \`instant\` command to expose development ports to the host for packages

```bash
instant package init ... --dev
```
