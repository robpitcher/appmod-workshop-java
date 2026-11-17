# Execute: Java 25 and Spring Boot 4.1.2 upgrade

## Cloud-agent instructions

Implement this plan in `robpitcher/appmod-workshop-java` and open one pull
request against `main`. The owner approved the decisions below on 2026-11-17.
Do not wait for another consolidation, intermediate-stage, or testing approval.
Do not merge or deploy. This issue body is a self-contained execution contract:
local assessment files, VS Code extensions, MCP tools, and developer-machine
schema paths are NOT prerequisites.

The local companion task list is `.metadata/tasks.json` beside this plan.
It is a portable checklist, not input to the installed modernization executor.
Do not repair the extension's incompatible schema or require its validation.
If these files are not on the remote branch, use the complete issue instructions
and add the plan/checklist to the PR as appropriate.

**Status:** Approved for cloud-agent execution; implementation and all build,
test, and security results remain unverified. No application changes were made
while preparing this plan.

## Approved scope and targets

| Component | Starting declaration | Approved destination |
|---|---|---|
| Java | 8 | Java 25 LTS |
| Spring Boot | 2.7.18 | 4.1.2 GA |
| Spring Framework | Boot-managed | 4.1.2 BOM-managed version; no independent pin |
| Common Annotations | `javax.annotation.PostConstruct` | Compatible Jakarta annotations in both modules |
| Maven | Wrapper 3.9.9 | Preserve unless a demonstrated compatibility problem requires change |

Use an available maintained Java 25 distribution; record vendor and exact
patch/build in the PR evidence. Verify the pinned Boot artifact and its
compatibility before editing. Do not silently substitute another final Boot
release or a preview. If the pinned release cannot be resolved from approved
feeds, report the exact error as a blocker.

This is one coordinated upgrade of the root parent plus `web` and `worker`.
Necessary Jakarta, Hibernate/JPA, Jackson/AMQP serialization, starter,
configuration, annotation-processor, and build compatibility changes are
authorized. Preserve web/worker message compatibility and existing behavior.
Keep Framework aligned through Boot dependency management.

Supporting changes to existing CI, startup scripts, and directly affected
documentation are authorized. Update contradictory Java 21/Boot 3 workshop
instructions without rewriting unrelated workshop steps. Retain Windows and
Unix startup paths. Do not trigger deployment workflows or use live resources.

**Out of scope:** AWS-to-Azure migration, authentication redesign, database
migration, new features, health-endpoint work, deployment, application
containerization, and unrelated refactoring. Disposable test containers are
allowed and are not a containerization deliverable.

## Assessment traceability

Source: `report-20261116223348`; use the existing report if present, without
requiring it or re-running assessment.

| Category / finding | Selected solution |
|---|---|
| Java Version Upgrade / Java Version is not the latest LTS | Upgrade Java Version [kbId: java-version-upgrade] |
| Framework Upgrade (Spring Boot) / Spring Boot Version Has Reached the End of OSS Support | Upgrade Spring Boot Version [kbId: spring-boot-upgrade] |
| Framework Upgrade (Spring Framework) / Spring Framework Version Has Reached the End of OSS Support | Upgrade Spring Framework Version [kbId: spring-framework-upgrade] |
| Deprecated APIs / The java.annotation (Common Annotations) module has been removed from OpenJDK 11 | Upgrade Deprecated APIs [kbId: deprecated-api-upgrade] |

The two lifecycle hooks are in:
- `web/src/main/java/com/microsoft/migration/assets/service/LocalFileStorageService.java`
- `worker/src/main/java/com/microsoft/migration/assets/worker/service/LocalFileProcessingService.java`

Convert only affected Java EE APIs; retain JDK APIs such as `javax.imageio`.

## Ordered execution checklist

### 001 - Establish baseline and disposable validation environment

- Inspect repository instructions and the current branch; preserve unrelated
  work. Inventory existing tests, configuration, CI, startup scripts, and
  dependency management.
- Record Java/Maven versions and run the existing reactor tests before edits,
  preferably with Java 8 matching the original declaration. Capture exact
  commands, exit codes, and per-module pass/fail/skip counts. If a baseline
  cannot run, record the technical reason rather than inventing results.
- Probe `docker info` and `node --version` independently in the cloud runtime.
  Local planning-machine probes found Docker functional and Node v26.13.0;
  that is NOT evidence about the cloud runtime.
- Prepare isolated PostgreSQL and RabbitMQ using existing dev-service intent,
  explicit stable container image versions recorded in evidence, unique
  resource names, readiness probes, and nonconflicting ports.
- Use the `dev` profile and one shared absolute temporary
  `local.storage.directory` for both modules. No real AWS/Azure endpoints,
  credentials, or production resources. Use only disposable test credentials.
- Do not invoke existing start/stop scripts blindly: they use fixed container
  names/ports and latest image tags. Scope all cleanup to this run's resources.
- The cloud agent may provision tools and disposable services within its own
  environment. Respect configured package registries; do not copy workstation
  credentials or bypass enterprise feed restrictions.

### 002 - Perform coordinated upgrade and focused regression coverage

- Use Java 17 with Boot 2.7.18 as a bridge if needed; do not attempt to validate
  Boot 2.7 on Java 25. Review the official Boot 3 migration guidance for
  2.7-to-3 changes and intervening minor-release notes.
- Stage through Boot 3.5.16 (Java 17 first, then Java 25), Boot 4.0.9 on Java 25,
  and finally Boot 4.1.2 on Java 25. These internal checkpoints are preapproved,
  not deployable deliverables. Intermediate releases do not need current OSS
  support; the final destination does. No approval pause is required.
- Check the Boot 4 migration guide, including modular starter/test changes,
  Jackson/message conversion, Jakarta persistence and Hibernate changes, and
  JDK 25 annotation-processor/Mockito compatibility where actually applicable.
- Preserve queue names, retry/ack behavior, message field contracts, storage
  selection, URLs, image processing, and existing external integration behavior.
- Add focused tests for the changed lifecycle hooks and affected message/JPA
  compatibility. Keep existing tests; no blanket `javax` replacement or
  unrelated production fixes. Update necessary CI/scripts/docs consistently.
- Run module tests at each affected stage, then full reactor verification at
  each Boot checkpoint. Log any baseline failures separately.

### 003 - Scan dependencies and apply compatible security fixes

- After the final target builds, scan the resolved dependencies of both
  modules using an available trusted scanner and current advisory data.
  Record scanner name/version, command, database timestamp, and coverage.
- Apply minimum compatible patches, preserving the approved Boot target/BOM
  alignment and avoiding unrelated major dependency upgrades.
- Report each remaining advisory with package/version, CVE/severity, fix
  availability, and why not fixed. Do not silently suppress advisories.
- No extra approval gate for documenting residual vulnerabilities: the owner
  chose reporting rather than an automatic zero-High/Critical completion gate.
  An unavailable/incomplete scan is UNVERIFIED, not "no vulnerabilities."
- Rerun affected tests and full reactor verification after remediation.

### 004 - Verify runtime flow and deliver evidence in one PR

- Execute the Testing Strategy below on the final dependency state.
- Include all scoped changes and runnable regression/integration/browser tests
  in one PR. Supply exact reproduction commands, JDK/dependency versions,
  baseline-vs-final results, runtime evidence, and residual vulnerabilities.
- Do not disable/delete tests, set skip flags, or hide failures to obtain a
  green build. Fix upgrade-caused failures. Document unrelated pre-existing
  failures by exact test name and baseline evidence; do not fix them without
  further authorization. If baseline defects block acceptance, mark the PR
  blocked/draft rather than claiming completion.
- If tool/service availability blocks required validation, retain completed
  work, mark that tier UNVERIFIED, and report a blocker with commands/errors.
  Do not wait indefinitely for an interactive answer.

## Testing Strategy

**appType:** server-rendered Thymeleaf web app plus asynchronous RabbitMQ worker.

**Existing test assets (discovered):** one JUnit 5/Mockito unit suite,
`worker/src/test/java/com/microsoft/migration/assets/worker/service/S3FileProcessingServiceTest.java`.
Reuse with minimal compatibility edits; no legacy browser/integration suite
was found in the initial inventory. Recheck on the execution branch.

**Canonical commands:** run from repository root with the checked-in wrapper.
- Linux/cloud: `sh ./mvnw -B -ntp test` (baseline and unit/regression runs).
- Linux/cloud: `sh ./mvnw -B -ntp verify` (final full reactor acceptance).
- Windows equivalents: `.\mvnw.cmd -B -ntp test` and
  `.\mvnw.cmd -B -ntp verify`.
- Targeted tests: add `-pl web -am` or `-pl worker -am` to the wrapper command.
  Do not use global skip/missing-test flags that could mask coverage gaps.
- Wire new integration tests into Maven `verify` (Failsafe if `*IT` naming is
  used); unit tests remain reachable through Maven `test`.

**primaryValidationStack:** JUnit 5/Mockito focused tests; full Spring
application-context integration tests using real disposable PostgreSQL and
RabbitMQ; MockMvc for controller/view/model assertions; headless Playwright
against the running web app and real worker for the rendered user journey.
Node/browser tooling is authorized only as needed for this validation. Keep
browser setup minimal and document its exact command; make full acceptance
reproducible through Maven `verify`, including browser invocation when
prerequisites are present. Do not silently make required tests opt-in.

**External dependency strategy and scaffold:**
- PostgreSQL: real isolated instance, unique test database/schema, no H2
  replacement as acceptance evidence. Verify persistence by read-back where
  the exercised code actually writes metadata; do not invent writes for the
  local-storage path.
- RabbitMQ: real isolated instance for startup and cross-module messaging;
  isolated vhost/test configuration preserving application queue contracts.
- Storage: unique temporary directory shared by both processes. Mock S3 in
  existing unit tests; do not contact live S3 for acceptance.
- Reuse a small shared test fixture/setup helper where useful; each module
  gets a full-context startup/initialization test. Both must run without manual
  configuration. Add cross-module serialization assertions for producer and
  consumer data contracts.
- Keep any `javax.imageio` usage; verify actual thumbnails rather than merely
  confirming a message was sent.

**Critical journeys and pass criteria:**
1. Startup: both contexts initialize under `dev`; local storage directories
   are created through their lifecycle hooks; web `/` redirects to `/storage`,
   gallery renders, and worker listener is ready.
2. Upload/process/view: use a unique valid image larger than 600 pixels
   (for example 1200x800). Submit the real upload form at `/storage/upload`.
   Assert the success redirect, original byte read-back through
   `/storage/view/{key}`, and real worker consumption producing a decodable
   600x400 thumbnail within a bounded 60-second polling timeout. Verify the
   original and thumbnail appear in the rendered gallery/detail flow.
3. Persistence/read-back: reload the gallery and retrieve stored bytes in a
   separate request after processing. Assert data comes from shared storage,
   not a mock. Exercise JPA write/read in an isolated integration test of the
   existing repository/model, preserving current mappings.
4. Failure/cleanup: empty upload returns the existing user-facing error and
   creates no stored asset/message; a missing image returns existing behavior.
   Delete a processed asset through `/storage/delete/{key}` and verify both
   original and thumbnail disappear. Capture UI assertions, not only HTTP 200.

Use at least three focused runnable test files spanning the web flow, worker
processing/initialization, and cross-module integration. These are scoped
regressions, not a broad new coverage project. Do not add authentication or
invent an authentication failure requirement where the app has none.

**Capability matrix / known gaps:**
- Docker unavailable: capture `docker info` error; real DB/MQ integration and
  full runtime acceptance are BLOCKED/UNVERIFIED. Mock-only tests can still
  run but cannot replace the required services. Do not contact live resources.
- Node/browser unavailable: independently attempt approved Node/browser setup.
  Record exact failure; continue MockMvc and real-infrastructure tests, but
  browser rendering remains UNVERIFIED and acceptance remains blocked.
- Docker and Node are independent axes: failure of one does not authorize
  skipping the other. No infrastructure or browser fallback counts as a pass
  for the owner-approved full runtime flow.

**Data and cleanup:** UUID asset names, fresh valid image fixture, isolated
schema/vhost/storage, bounded polling and readiness timeouts. Close processes
and remove only this run's named containers/test data in teardown. Never
delete broad directories or interfere with other processes/services.

**Evidence / reviewer expectations:** capture every command and exit code;
per-module and per-tier passed/failed/skipped counts; startup signals;
resolved Java/Boot/Framework versions; UI screenshot or Playwright trace;
thumbnail dimensions and read-back assertions; advisory results and gaps.
Final summary must distinguish PASS, FAIL, BLOCKED, and UNVERIFIED. A nonzero
exit code is FAIL even if some tests passed. No final success claim while a
required tier fails, is skipped, or is unverified.

## Verified planning references

Checked 2026-11-17; dynamic documentation can change. Resolve exact pinned
artifacts/effective POMs at execution and record managed versions, not just
minimum Framework requirements.

- [Spring Boot project: current GA 4.1.2](https://spring.io/projects/spring-boot)
- [Boot 4.1.2 requirements: Java 17 through 27; Framework 7.0.10 minimum](https://docs.spring.io/spring-boot/4.1/system-requirements.html)
- [Boot support policy and supported release links](https://github.com/spring-projects/spring-boot/wiki/Supported-Versions)
- [Boot 3.5.16 requirements: Java 17 through 25](https://docs.spring.io/spring-boot/3.5/system-requirements.html)
- [Boot 4.0.9 requirements](https://docs.spring.io/spring-boot/4.0/system-requirements.html)
- [Boot 2.7 to 3 migration](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide)
- [Boot 3.5 to 4 migration](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-4.0-Migration-Guide)

## Completion checklist

- [ ] Java 25 and Boot 4.1.2 effective in parent and both modules.
- [ ] Framework remains Boot-managed; both annotation lifecycle hooks work.
- [ ] Full Maven reactor `verify` passes without hiding tests.
- [ ] Focused unit/context/integration tests pass for both modules.
- [ ] Real local upload -> worker thumbnail -> gallery -> delete flow passes.
- [ ] Dependency scan performed; compatible fixes applied and residuals listed.
- [ ] Directly affected CI/scripts/docs updated; no deployment triggered.
- [ ] Evidence, blockers, and reproduction commands included in one PR.
