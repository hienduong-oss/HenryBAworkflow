#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_ROOT="${BA_KIT_CODEX_SOURCE_ROOT:-${ROOT_DIR}/codex}"
SOURCE_SKILLS="${SOURCE_ROOT}/skills"
SOURCE_AGENTS="${SOURCE_ROOT}/agents"
TARGET_HOME="${HOME}/.codex"
TARGET_SKILLS="${TARGET_HOME}/skills"
TARGET_AGENTS="${TARGET_HOME}/agents"
TARGET_CONFIG="${TARGET_HOME}/config.toml"

if [[ ! -d "${SOURCE_SKILLS}" ]] && [[ ! -d "${SOURCE_AGENTS}" ]]; then
  echo "BA-kit Codex conversion not found."
  echo "Expected converted assets under: ${SOURCE_ROOT}/skills and ${SOURCE_ROOT}/agents"
  echo "Set BA_KIT_CODEX_SOURCE_ROOT if your converted assets live elsewhere."
  exit 1
fi

node - "${SOURCE_SKILLS}" "${SOURCE_AGENTS}" "${TARGET_HOME}" "${TARGET_SKILLS}" "${TARGET_AGENTS}" "${TARGET_CONFIG}" <<'NODE'
const fs = require("node:fs");
const path = require("node:path");

const [sourceSkills, sourceAgents, targetHome, targetSkills, targetAgents, targetConfig] =
  process.argv.slice(2);

const ensureDir = (dirPath) => {
  fs.mkdirSync(dirPath, { recursive: true });
};

const copyContents = (sourceDir, targetDir) => {
  if (!fs.existsSync(sourceDir)) {
    return [];
  }

  ensureDir(targetDir);
  const copied = [];

  for (const entry of fs.readdirSync(sourceDir, { withFileTypes: true })) {
    const sourcePath = path.join(sourceDir, entry.name);
    const targetPath = path.join(targetDir, entry.name);
    fs.cpSync(sourcePath, targetPath, {
      recursive: true,
      force: true,
      dereference: false,
      preserveTimestamps: true,
    });
    copied.push(targetPath);
  }

  return copied;
};

const parseField = (content, field) => {
  const match = content.match(new RegExp(`^${field}\\s*=\\s*"((?:\\\\.|[^"])*)"$`, "m"));
  if (!match) {
    return "";
  }

  return match[1].replace(/\\"/g, '"');
};

const escapeTomlString = (value) => value.replace(/\\/g, "\\\\").replace(/"/g, '\\"');

const appendAgentRegistration = (configPath, agentTomlPath) => {
  const content = fs.readFileSync(agentTomlPath, "utf8");
  const agentName =
    parseField(content, "name") || path.basename(agentTomlPath, path.extname(agentTomlPath));
  const description =
    parseField(content, "description") || `Codex BA agent from ${path.basename(agentTomlPath)}`;
  const registrationHeader = `[agents.${agentName}]`;
  const registrationBlock = [
    registrationHeader,
    `description = "${escapeTomlString(description)}"`,
    `config_file = "agents/${path.basename(agentTomlPath)}"`,
    "",
  ].join("\n");

  const configContent = fs.existsSync(configPath) ? fs.readFileSync(configPath, "utf8") : "";
  const headerPattern = new RegExp(`^\\[agents\\.${agentName.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}\\]$`, "m");
  if (headerPattern.test(configContent)) {
    return false;
  }

  ensureDir(path.dirname(configPath));
  const updated =
    configContent.length === 0
      ? registrationBlock
      : `${configContent}${configContent.endsWith("\n") ? "\n" : "\n\n"}${registrationBlock}`;
  fs.writeFileSync(configPath, updated);
  return true;
};

ensureDir(targetHome);
ensureDir(targetSkills);
ensureDir(targetAgents);

const installedSkills = copyContents(sourceSkills, targetSkills);
const installedAgents = copyContents(sourceAgents, targetAgents);

const registrations = [];
for (const entry of installedAgents) {
  if (entry.endsWith(".toml")) {
    if (appendAgentRegistration(targetConfig, entry)) {
      registrations.push(path.basename(entry, ".toml"));
    }
  }
}

console.log(`Installed skills into ${targetSkills}`);
console.log(`Installed agents into ${targetAgents}`);
if (installedSkills.length === 0) {
  console.log("No skill files were found to install.");
}
if (installedAgents.length === 0) {
  console.log("No agent files were found to install.");
}
if (registrations.length > 0) {
  console.log(`Registered Codex agents in ${targetConfig}: ${registrations.join(", ")}`);
} else {
  console.log(`No new agent registrations were needed in ${targetConfig}`);
}
NODE
