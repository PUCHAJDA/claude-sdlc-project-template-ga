# claude-sdlc-project-template (github actions)

Szablon startowy projektu prowadzonego zgodnie z **AI-native SDLC**
([playbook Anthropic](https://claude.com/resources/articles/the-ai-native-sdlc-playbook)).

Artefakty czytane przez Claude (`CLAUDE.md`, skille, hooki, prompty) są po angielsku —
modele trzymają się ich wtedy ściślej. Dokumentacja dla ludzi po polsku.

## Idea

Kod przestał być wąskim gardłem; planowanie, review i wdrożenie nadal chodzą w tempie
człowieka. Ten szablon zamienia liniowy proces z przekazywaniem pracy na pętlę, w której
**każdy etap commituje artefakt czytany przez następny**:

```
intent.md  →  spec.md  →  plan.md  →  diff + testy  →  PR z review  →  incydent
    ↑                                                                      │
    └──────────────────────────────────────────────────────────────────────┘
```

Historia commitów jest audit trailem — nie ma osobnego procesu „na zgodność".
Pełny opis sześciu etapów, ról i metryk: **[docs/sdlc/00-OVERVIEW.md](docs/sdlc/00-OVERVIEW.md)**.

## Jak wystartować projekt

Kliknij **Use this template** na GitHubie (albo sklonuj i usuń `.git`), a potem podmień
placeholder nazwy projektu:

```bash
grep -rl '{{PROJECT_NAME}}' . | xargs sed -i 's/{{PROJECT_NAME}}/moj-projekt/g'
chmod +x .claude/hooks/*.sh evals/*.sh
```

PowerShell:

```powershell
Get-ChildItem -Recurse -File -Force |
  Where-Object { (Get-Content $_ -Raw -EA SilentlyContinue) -match '\{\{PROJECT_NAME\}\}' } |
  ForEach-Object {
    [IO.File]::WriteAllText($_.FullName,
      ([IO.File]::ReadAllText($_.FullName) -replace '\{\{PROJECT_NAME\}\}','moj-projekt'),
      (New-Object Text.UTF8Encoding($false)))
  }
```

## Zawartość

| Ścieżka | Etap | Do czego |
|---|---|---|
| [CLAUDE.md](CLAUDE.md) | Build | Pamięć projektu: komendy, konwencje, architektura, częste błędy Claude |
| [REVIEW.md](REVIEW.md) | Deploy | Przebiegi review, próg „Important", limit nitów |
| [PROMPTS.md](PROMPTS.md) | wszystkie | Siedem promptów do skopiowania, po jednym na etap |
| [.claude/commands/](.claude/commands/) | wszystkie | `/sdlc-intent` `/sdlc-spec` `/sdlc-plan` `/sdlc-verify` `/sdlc-incident` |
| [.claude/skills/](.claude/skills/) | Design, Build, Test | Wiedza instytucjonalna, odpala się po triggerze |
| [.claude/agents/](.claude/agents/) | Build, Test | `verifier` (uruchamia i raportuje, nie naprawia), `spec-reviewer` |
| [.claude/hooks/](.claude/hooks/) | Build, Deploy | Ochrona ścieżek, blokada edycji testów w TDD, bramka na produkcję |
| [docs/sdlc/](docs/sdlc/) | wszystkie | Szablony artefaktów, progi `bands.yaml`, `LESSONS.md` |
| [evals/](evals/) | Test | Zadania ewaluacyjne z kryteriami akceptacji |
| [.github/workflows/](.github/workflows/) | Test, Deploy | Review PR i evale przy zmianie `CLAUDE.md` lub `.claude/**` |

## Pierwszy tydzień

Nie włączaj wszystkiego naraz — guardraile mają dojrzewać razem z projektem.

1. **Dzień 1** — uzupełnij `Makefile` (celowo kończy się `exit 1`; pusty target zwracający
   zero jest gorszy niż brak targetu, bo daje Claude zielone światło na zepsutym kodzie).
   Potem `/init` i przytnij `CLAUDE.md` do jednej strony.
2. **Dzień 2–3** — pracuj w trybie plan (Shift+Tab), commituj `docs/sdlc/plan.md`.
3. **Tydzień 1** — włącz hooki `protect-paths` i `format-after-edit`. Dopisuj do `CLAUDE.md`
   każdą poprawkę, którą podajesz Claude **drugi raz**.
4. **Tydzień 2+** — evale w CI (wymagają `ANTHROPIC_API_KEY` w sekretach repo), review PR
   przez agenta, `release-gate` na produkcję.
5. **Później** — tryb auto i równoległe sesje na worktree. Dopiero gdy powyższe działa.

## Dwie zasady, o których łatwo zapomnieć

**Skill doradza, hook blokuje.** Polityka bez pokrycia w hooku albo checku na PR jest
sugestią — Claude da się z niej wyprowadzić, a w CI nie zadziała w ogóle.

**„Done" znaczy zweryfikowane.** Wklejony output `make check`, nie zdanie „powinno działać".

## Governance dla regulowanego enterprise

Szablon zatrzymuje się na ustawieniach zespołowych w `.claude/settings.json`, które każdy
może nadpisać lokalnie. Bariery nienegocjowalne przenosi się do **managed settings** poza
repo, zarządzanych przez IT: deny-listy na sekrety i narzędzia sieciowe,
`disableBypassPermissionsMode`, `allowManagedPermissionRulesOnly`, sandbox z allowlistą
domen, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `requiredMinimumVersion`.
Szczegóły: [docs.claude.com — settings](https://docs.claude.com/en/docs/claude-code/settings).
