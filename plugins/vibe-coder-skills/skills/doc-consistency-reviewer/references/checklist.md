# Review Checklist

## Table of Contents

1. [README Features & Functionality](#1-readme-features--functionality)
2. [External Interfaces & Contracts](#2-external-interfaces--contracts)
3. [Configuration & Environment Variables](#3-configuration--environment-variables)
4. [Security & Permissions](#4-security--permissions)
5. [Execution & Scripts](#5-execution--scripts)
6. [Views & Module Behavior](#6-views--module-behavior)
7. [Testing & QA](#7-testing--qa)
8. [Terminology & Naming](#8-terminology--naming)

---

## 1. README Features & Functionality

- [ ] Are all features/functionalities in README clearly implemented or accessible?
- [ ] Are there deprecated or hidden features still listed in README?
- [ ] Are the supported platforms/protocols/formats claimed in docs consistent with actual code support?
- [ ] Are version numbers and dependency versions consistent with package.json/requirements.txt?
- [ ] Does the project architecture diagram reflect the current directory structure?

## 2. External Interfaces & Contracts

- [ ] Are API examples, parameters, and return values in docs consistent with OpenAPI/proto/schema/TS types?
- [ ] Do endpoints/methods claimed in docs actually exist in code?
- [ ] Are there new interfaces in code that are not yet updated in docs?
- [ ] Are request/response field names consistent?
- [ ] Are required/optional parameters correctly marked?
- [ ] Are default values consistent with implementation?
- [ ] Are error codes/status codes completely listed?

## 3. Configuration & Environment Variables

- [ ] Are environment variable names listed in docs consistent with those read in code?
- [ ] Are environment variable default values consistent with fallbacks in code?
- [ ] Are required environment variables correctly marked?
- [ ] Do Feature Flags actually exist in code?
- [ ] Are configuration file paths correct?
- [ ] Are configuration item types (string/number/boolean) correct?

## 4. Security & Permissions

- [ ] Is the authentication method consistent with implementation (JWT/Session/OAuth)?
- [ ] Are role/permission/scope definitions consistent with check logic in code?
- [ ] Are security settings like sandbox/contextIsolation enabled as described in docs?
- [ ] Is Encryption/HTTPS configured as described in docs?
- [ ] Is CORS policy consistent with doc description?
- [ ] Is CSP policy consistent with doc description?

## 5. Execution & Scripts

- [ ] Are startup commands consistent with package.json scripts?
- [ ] Can build commands be executed successfully?
- [ ] Are test commands consistent with test framework configuration?
- [ ] Are deployment commands consistent with CI/CD configuration?
- [ ] Can "Quick Start" steps be run successfully in one go?
- [ ] Are removed scripts or directories referenced?
- [ ] Are dependency installation commands correct?

## 6. Views & Module Behavior

- [ ] Do key pages/modules described in docs have corresponding components?
- [ ] Do buttons/switches/options mentioned in docs actually exist?
- [ ] Is component behavior consistent with doc description?
- [ ] Are route paths consistent with docs?
- [ ] Do screenshots reflect current UI?

## 7. Testing & QA

- [ ] Is the test framework consistent with doc description?
- [ ] Can test commands be executed successfully?
- [ ] Is coverage configuration consistent with doc claims?
- [ ] Is CI flow consistent with doc description?

## 8. Terminology & Naming

- [ ] Are type names/enum names/module names consistent with doc terminology?
- [ ] Do status enum values correspond one-to-one with descriptions in docs?
- [ ] Can example code be compiled/run?
- [ ] Have referenced functions/types/modules been renamed or moved?
- [ ] Are links valid (no 404)?

---

## Project Type Specific Checks

### Electron Project

- [ ] Are main/renderer process boundaries consistent with doc description?
- [ ] Are APIs exposed by preload scripts consistent with docs?
- [ ] Are contextIsolation/nodeIntegration settings as described in docs?
- [ ] Are IPC channel names consistent with docs?
- [ ] Is window configuration consistent with doc description?

### Web Frontend Project

- [ ] Is route configuration consistent with doc description?
- [ ] Is state management scheme consistent with docs?
- [ ] Is component library version consistent with docs?
- [ ] Is build output directory consistent with docs?

### Backend API Project

- [ ] Is middleware order consistent with doc description?
- [ ] Is database schema consistent with docs?
- [ ] Is cache policy consistent with doc description?
- [ ] Is rate limiting configuration consistent with docs?

### CLI Tool Project

- [ ] Are command names consistent with docs?
- [ ] Are options/arguments consistent with docs?
- [ ] Is output format consistent with doc examples?
- [ ] Is exit code consistent with doc description?
