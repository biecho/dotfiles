# Clean Architecture — Review Checklist

Systematic audit checklist for reviewing codebases against Clean Architecture principles.

## Phase 1: Map the Structure

Before checking violations, understand what exists:

1. Identify the language and framework
2. Map directories/modules to architectural layers
3. Identify the composition root (where DI wiring happens)
4. List external dependencies (DB, APIs, message queues)

## Phase 2: Dependency Direction Audit

### Entity/Domain Layer Purity

Check that domain entities have ZERO framework imports.

**Grep patterns to detect violations:**

```bash
# Python — domain layer importing frameworks
grep -rn "from sqlalchemy\|from flask\|from fastapi\|from django\|from pydantic\|import requests" src/domain/

# TypeScript — domain importing infrastructure
grep -rn "from.*infrastructure\|from.*prisma\|from.*typeorm\|from.*express" src/domain/

# Go — domain importing external packages
grep -rn '"github.com/\|"gorm.io\|"net/http"' internal/domain/

# Java — domain importing Spring/JPA
grep -rn "import org.springframework\|import javax.persistence\|import jakarta.persistence" domain/src/

# C# — domain importing EF Core or ASP.NET
grep -rn "using Microsoft.EntityFrameworkCore\|using Microsoft.AspNetCore\|using System.ComponentModel.DataAnnotations" Domain/

# Rust — domain crate depending on external crates
grep -n "^\[dependencies\]" domain/Cargo.toml  # Should be empty or near-empty
```

### Application Layer Dependencies

Application layer should only import from domain:

```bash
# Python
grep -rn "from infrastructure\|from presentation\|from sqlalchemy\|from flask" src/application/

# TypeScript
grep -rn "from.*infrastructure\|from.*presentation\|from.*express\|from.*prisma" src/application/
```

### Import Direction Summary

Run a full import graph and verify arrows point inward:

```bash
# Python — quick dependency check
python -c "
import ast, os, sys
for root, dirs, files in os.walk('src'):
    for f in files:
        if f.endswith('.py'):
            path = os.path.join(root, f)
            layer = path.split('/')[1] if len(path.split('/')) > 1 else '?'
            with open(path) as fh:
                for node in ast.walk(ast.parse(fh.read())):
                    if isinstance(node, (ast.Import, ast.ImportFrom)):
                        mod = getattr(node, 'module', '') or ''
                        if mod.startswith('src.'):
                            target_layer = mod.split('.')[1]
                            print(f'{layer} -> {target_layer}  ({path})')
"
```

## Phase 3: Boundary Crossing Audit

### Check: Framework types crossing inward

| Violation | What to look for |
|-----------|-----------------|
| HTTP objects in use cases | `Request`, `Response`, `HttpContext` parameters in use case methods |
| ORM models in use cases | Use case methods accepting/returning ORM entities |
| Framework DTOs as domain | Pydantic/marshmallow models used as domain entities |
| Serialization in entities | `@JsonProperty`, `to_dict()`, `toJSON()` on domain objects |

### Check: Domain entities leaking outward

| Violation | What to look for |
|-----------|-----------------|
| Entity as API response | Controller returning domain entity directly |
| Entity in DB layer | Domain entity with ORM annotations/decorators |
| Entity in message payload | Domain entity serialized to message queue |

### Check: Proper mapper existence

For each boundary, verify a mapper/converter exists:

```
Controller ←→ Use Case: Request DTO mapper exists?
Use Case ←→ Repository: Entity ←→ DB model mapper exists?
Controller ←→ Client: Response DTO mapper exists?
```

## Phase 4: Layer Responsibility Audit

### Business Logic Placement

```bash
# Business logic in controllers (violation)
# Look for: conditional logic, calculations, validations beyond input format
grep -rn "if.*price\|if.*status\|if.*amount\|calculate\|validate.*business" src/presentation/ src/infrastructure/

# SQL in use cases (violation)
grep -rn "SELECT\|INSERT\|UPDATE\|DELETE\|query\|execute.*sql" src/application/ src/domain/
```

### Use Case Quality

For each use case, check:

- [ ] Has a single public `execute()` / `handle()` method
- [ ] Orchestrates entities, doesn't duplicate their logic
- [ ] Accepts a request DTO, returns a response DTO
- [ ] Dependencies are injected interfaces, not concrete classes
- [ ] Does NOT contain: HTTP status codes, SQL, serialization logic

### Controller Quality

For each controller, check:

- [ ] Only translates external format → use case request
- [ ] Only translates use case response → external format
- [ ] Does NOT contain business logic or validation beyond input parsing
- [ ] Does NOT call repositories directly (goes through use cases)

### Repository Implementation Quality

For each repository, check:

- [ ] Implements an interface defined in domain/application layer
- [ ] Maps between ORM/DB models and domain entities
- [ ] Does NOT leak DB-specific types to callers
- [ ] Handles DB-specific errors, translates to domain exceptions

## Phase 5: Anti-Pattern Detection

### 1. Framework Leak

**Symptom:** Entity or use case imports a framework library.
**Grep:**
```bash
grep -rn "import.*sqlalchemy\|import.*django\|import.*spring\|import.*express" src/domain/ src/application/
```
**Fix:** Extract an interface in the inner layer, implement in infrastructure.

### 2. Anemic Use Case

**Symptom:** Use case is just `return repo.save(entity)`.
**Detection:** Use cases with < 5 lines of logic (excluding boilerplate).
**Fix:** If the use case truly has no orchestration, consider whether you need it. For
simple CRUD, a thinner architecture is fine.

### 3. Phantom Interface

**Symptom:** Interface with exactly one implementation, never mocked in tests.
**Detection:**
```bash
# Find interfaces and count implementations
grep -rn "class.*Repository\|interface.*Repository" --include="*.py" --include="*.ts" --include="*.java"
# Then check: how many classes implement each?
```
**Fix:** Remove the interface if it provides no testing or flexibility benefit.

### 4. God Model

**Symptom:** Single class used as DB entity, API response, domain model, and command input.
**Detection:** Class with both `@Entity`/`@Table` AND `@JsonProperty`/serialization decorators.
**Fix:** Create separate models per layer with mappers between them.

### 5. Layer Bypass

**Symptom:** Controller calls repository directly, skipping use case layer.
**Detection:**
```bash
grep -rn "Repository\|repository" src/presentation/
```
**Fix:** Introduce a use case even if thin — it's the place where future logic will go.

### 6. Test Over-Mocking

**Symptom:** Tests mock domain entities instead of using real objects.
**Detection:** Test files that mock entity constructors or entity methods.
**Fix:** Use real entities in tests. Only mock I/O boundaries (repos, external services).

### 7. Ceremony Overload

**Symptom:** Trivial CRUD feature goes through Entity → Use Case → Repository Interface →
Repository Impl → Controller → Presenter with identical data at every layer.
**Detection:** Look for use cases that are pure pass-through.
**Fix:** Right-size the architecture. Not every feature needs all layers.

### 8. Identity Copy

**Symptom:** Mapper copies identical fields between identical structures.
**Detection:** Mapper functions where every field name and type matches.
**Fix:** If the models truly have no differences, merge them or eliminate the mapping.

## Phase 6: Report Template

```markdown
# Clean Architecture Review — [Project Name]

## Structure Mapping
| Directory | Layer | Status |
|-----------|-------|--------|
| src/domain/ | Domain/Entities | OK / Issues |
| src/application/ | Application/Use Cases | OK / Issues |
| ... | ... | ... |

## Findings
| # | File:Line | Violation | Severity | Description | Suggested Fix |
|---|-----------|-----------|----------|-------------|---------------|
| 1 | src/domain/user.py:3 | Framework Leak | High | Imports SQLAlchemy | Extract repository interface |
| 2 | src/api/controller.py:45 | Layer Bypass | Medium | Calls UserRepo directly | Route through RegisterUserUseCase |

## Summary
- Critical violations: N
- High severity: N
- Medium severity: N
- Low severity: N

## Recommendations
1. ...
2. ...
```

## Architecture Enforcement Tools

| Language | Tool | What it does |
|----------|------|-------------|
| Python | `import-linter` | Enforces import direction rules in CI |
| Go | `go-cleanarch` | Linter that checks architectural layer violations |
| Java | ArchUnit | Unit tests that verify architectural rules |
| .NET | NetArchTest, NDepend | Architecture testing and dependency analysis |
| PHP | Deptrac | Dependency tracing and rule enforcement |
| TypeScript | `dependency-cruiser` | Validates and visualizes dependency graphs |
| Kotlin | Gradle module boundaries | Compiler-enforced via separate modules |
| Rust | Crate boundaries | Compiler-enforced via workspace crates |
