# claude-sdlc-project-template (github actions)

Szablon startowy projektu prowadzonego zgodnie z **AI-native SDLC**
([playbook Anthropic](https://claude.com/resources/articles/the-ai-native-sdlc-playbook)).

> **To jest README szablonu.** Po założeniu projektu zastąp go własnym — opisującym Twój
> projekt, a nie szablon. Opis procesu zostaje w [docs/sdlc/00-OVERVIEW.md](docs/sdlc/00-OVERVIEW.md).

Pliki czytane przez Claude (`CLAUDE.md`, skille, hooki, prompty) są po angielsku — modele
trzymają się ich wtedy ściślej. Dokumentacja dla ludzi po polsku.

---

## Czym to jest, w trzydzieści sekund

Kod przestał być wąskim gardłem. Planowanie, review i wdrożenie nadal chodzą w tempie
człowieka, więc AI przyspiesza jeden odcinek, a korek przenosi się dalej.

Szablon zamienia liniowy proces z przekazywaniem pracy na pętlę, w której **każdy etap
zostawia w repo plik czytany przez następny**:

```
intent.md  →  spec.md  →  plan.md  →  diff + testy  →  PR z review  →  incydent
 problem      wymagania    plan        implementacja    wdrożenie      produkcja
    ↑                                                                      │
    └──────────────────────────────────────────────────────────────────────┘
```

Ponieważ wszystko jest commitem, historia repo jest jednocześnie audit trailem — nie ma
osobnego procesu „na zgodność", który trzeba prowadzić obok.

Praktyczna konsekwencja: **brakujący plik to nie formalność do nadrobienia, tylko sygnał,
że decyzja nie zapadła.** Nie ma `spec.md` — nie ma czego planować.

---

## Start: pierwsze dziesięć minut

**1. Załóż projekt z szablonu.** Na GitHubie kliknij **Use this template**, albo sklonuj
i usuń historię:

```bash
git clone https://github.com/PUCHAJDA/claude-sdlc-project-template-ga.git moj-projekt
cd moj-projekt && rm -rf .git && git init
```

**2. Podmień nazwę projektu.** Szablon ma w kilku plikach placeholder `{{PROJECT_NAME}}`:

```bash
grep -rl '{{PROJECT_NAME}}' . | xargs sed -i 's/{{PROJECT_NAME}}/moj-projekt/g'
chmod +x .claude/hooks/*.sh evals/*.sh
```

<details>
<summary>To samo w PowerShell</summary>

```powershell
Get-ChildItem -Recurse -File -Force |
  Where-Object { (Get-Content $_ -Raw -EA SilentlyContinue) -match '\{\{PROJECT_NAME\}\}' } |
  ForEach-Object {
    [IO.File]::WriteAllText($_.FullName,
      ([IO.File]::ReadAllText($_.FullName) -replace '\{\{PROJECT_NAME\}\}','moj-projekt'),
      (New-Object Text.UTF8Encoding($false)))
  }
```
</details>

(Komenda przerobi też przykłady w tym README — nieszkodliwie, bo i tak zastępujesz go
własnym. Placeholder siedzi realnie w `CLAUDE.md`, `REVIEW.md`, `PROMPTS.md`,
`docs/sdlc/00-OVERVIEW.md` i `evals/README.md`.)

**3. Uzupełnij `Makefile`.** To jest ten krok, którego nie da się pominąć. Wszystkie targety
są zaślepkami kończącymi się `exit 1` — podmień je na komendy swojego stacku:

```make
install:
	npm ci
test:
	npm test
lint:
	npm run lint
```

Dlaczego to takie ważne: `make check` jest **jedynym sposobem, w jaki Claude może sprawdzić
własną pracę**. Komenda zwracająca kod wyjścia 0 albo nie-zero to sygnał, którego model nie
może sobie wmówić. Bez tego „zrobione" znaczy tyle, co „model uznał, że zrobione" — i tak
powstaje kod opisany pewnym tonem, który nie działa.

Zaślepki celowo kończą się błędem. Pusty target zwracający zero byłby gorszy niż jego brak,
bo dałby Claude zielone światło na zepsutym kodzie.

**4. Odpal Claude i wygeneruj pamięć projektu.**

```bash
claude
/init
```

Potem **przytnij `CLAUDE.md` do jednej strony**. `/init` generuje dużo; zostaw komendy,
konwencje, architekturę i sekcję „Things Claude gets wrong". Ten plik jest czytany przy
każdej turze, więc jego długość kosztuje uwagę, nie tylko tokeny.

**5. Pierwsze zadanie.**

```
/sdlc-intent "użytkownicy kopiują dane z raportu ręcznie do Excela"
```

---

## Jak to wygląda w praktyce

Jedna zmiana, od pomysłu do produkcji. Realne komendy, realne pliki w repo.

### Etap 1 — Plan: co właściwie jest problemem

```
/sdlc-intent "użytkownicy kopiują dane z raportu ręcznie do Excela"
```

Claude **przesłucha Cię, zamiast od razu proponować rozwiązanie**. Zapyta, kto konkretnie
jest zablokowany, ile razy dziennie, co się stanie, jeśli nic nie zrobimy, i które
ograniczenie uznajesz za sztywne, choć nie jest. Jeśli nie padło pytanie, na które nie
znasz odpowiedzi, przesłuchanie było za płytkie.

Gdy powiesz „write it", powstaje `docs/sdlc/intent.md`. Rzeczy, co do których byłeś
niejasny, trafiają do **Open questions dosłownie** — nierozstrzygnięte. Zgadnięta odpowiedź
wygląda jak postęp, a jest defektem przeniesionym o etap dalej.

### Etap 2 — Design: co dokładnie ma powstać

```
/sdlc-spec
```

Powstaje `docs/sdlc/spec.md` z kryteriami akceptacji, z których **każde da się zamienić na
test**. Po drodze Claude stosuje skille z `.claude/skills/` i zgłasza zastrzeżenia:

> **CONCERN (security):** Eksport udostępnia dane klientów nowym kanałem. Polityka wymaga
> autoryzacji per rekord. Wymaga decyzji przed buildem.

Zastrzeżenie zostaje **otwarte**. Skill nie „rozwiązuje" go po cichu zawężając zakres —
od podjęcia tej decyzji jest człowiek. Na koniec subagent `spec-reviewer` sprawdza spec
przed implementacją i mówi `READY TO PLAN` albo `NEEDS REVISION`.

### Etap 3 — Build: jak to zrobić

Naciśnij **Shift+Tab** (tryb plan — Claude nie może wtedy edytować plików), potem:

```
/sdlc-plan
```

Dostajesz plan z listą plików, testów per kryterium i — to jest istotne — odpowiedzią na
pytanie „jakie jest tu najbardziej ryzykowne założenie i jak je tanio sprawdzić, zanim
napiszę resztę". Po akceptacji powstaje `docs/sdlc/plan.md`, commitowany **przed** kodem.

Teraz Claude implementuje. Po drodze pilnują go hooki: nie ruszy chronionych ścieżek,
a po każdej edycji sformatuje plik.

### Etap 4 — Test: czy to na pewno działa

```
/sdlc-verify
```

Uruchamia subagenta `verifier` w osobnej sesji. **Nie naprawia niczego — tylko sprawdza
i raportuje.** To celowe: sesja, która pisała kod, jest najgorszym sędzią tego, czy kod
działa, bo wie, co miała na myśli. Verifier wie tylko, co faktycznie powstało.

Przy naprawie buga kolejność jest odwrotna niż zwykle: najpierw test, który **się wywala**,
commitowany osobno jako dowód, że bug istniał. Dopiero potem poprawka. Hook `no-test-edits`
blokuje wtedy edycję testów, żeby „zrobienie żeby przechodziło" nie polegało na zmianie
pytania zamiast odpowiedzi.

### Etap 5 — Deploy: review i wdrożenie

Podnosisz PR. Workflow [claude-review.yml](.github/workflows/claude-review.yml) ocenia diff
według [REVIEW.md](REVIEW.md) — ale **wobec `spec.md` i `plan.md`**, nie wobec tego, co agent
sam by napisał. Cokolwiek robi diff, a czego plan nie przewidywał, jest findingiem, choćby
wyglądało rozsądnie.

Człowiek nadal zatwierdza przez branch protection. Komentarz `@claude` odpala poprawkę.
Wejście na produkcję blokuje hook `release-gate`, dopóki ktoś imiennie nie autoryzuje
release'u — ten sam efekt co komitet zmian, bez spotkania.

### Etap 6 — Maintain: produkcja wraca na początek

```
/sdlc-incident "error_rate_5xx 3σ powyżej baseline od 14:20, po deployu 14:12"
```

Progi z [docs/sdlc/bands.yaml](docs/sdlc/bands.yaml) decydują, ile Claude wolno: przy 1σ
tylko log, przy 2σ diagnoza **bez prawa edycji**, przy 3σ dopiero PR albo runbook z listy.
Wykrywanie jest deterministyczne — Claude wchodzi do interpretacji, nie do decyzji „czy to
w ogóle anomalia".

Na koniec incydent zostawia trzy rzeczy: wpis w `LESSONS.md`, **nowy eval** (bez tego ta sama
regresja wróci) i nowy `intent.md` dla prawdziwego problemu, nie dla objawu. Pętla się zamyka.

---

## Czym zastąpić `Makefile`

`make` nie jest tu wymogiem technicznym — jest **warstwą pośrednią**. W szablonie jest
**25 odwołań do `make` w 12 plikach**: `CLAUDE.md`, oba zadania ewaluacyjne, subagent
`verifier`, skill `tdd-bugfix`, `REVIEW.md`, oba workflow i runbooki w `bands.yaml`. Żaden
z nich nie wie, czy pod spodem jest pytest, npm czy cargo — wszystkie wołają `make check`.

Dzięki temu szablon jest agnostyczny stackowo, a zmiana test runnera to jedna linia zamiast
dwudziestu pięciu. `make` wybrałem, bo jest wszędzie i nie dokłada zależności.

Jeśli Twój zespół używa czego innego, podmień — tylko konsekwentnie:

<details>
<summary><b>just</b> — <code>justfile</code></summary>

```just
install:
    npm ci
test:
    npm test
lint:
    npm run lint
check: lint test
```
Komendy stają się `just check`.
</details>

<details>
<summary><b>Task</b> — <code>Taskfile.yml</code></summary>

```yaml
version: '3'
tasks:
  install: { cmds: [npm ci] }
  test:    { cmds: [npm test] }
  lint:    { cmds: [npm run lint] }
  check:   { deps: [lint, test] }
```
Komendy stają się `task check`.
</details>

<details>
<summary><b>npm run</b> — <code>package.json</code></summary>

```json
{ "scripts": {
  "install:deps": "npm ci",
  "test": "vitest run",
  "lint": "eslint .",
  "check": "npm run lint && npm test"
} }
```
Komendy stają się `npm run check`.
</details>

<details>
<summary><b>nx</b> — monorepo</summary>

```bash
nx run-many -t lint test   # odpowiednik make check
```
</details>

### Co trzeba zmienić przy podmianie

Znajdź wszystkie odwołania i podmień nazwę komendy:

```bash
grep -rnoE 'make (install|test|lint|typecheck|check|dev|rollback|quarantine)\b' \
  --include='*.md' --include='*.yml' --include='*.yaml' --include='*.sh' . \
  | grep -v '^./README.md:'
```

Zwróci dokładnie te 25 odwołań. Wzorzec jest zawężony do nazw targetów celowo — samo
`grep 'make '` łapie też angielskie „make sure" i „make it" w prozie skilli i promptów.
Flaga `-o` jest istotna, bo kilka linii zawiera po dwa–trzy wywołania naraz.

**Uwaga na jedną pułapkę.** Workflow evali ma bramkę, która sprawdza, czy projekt jest już
podpięty — i traktuje **brak `Makefile`** jako „jeszcze nie":

```yaml
if [ ! -f Makefile ] || grep -q 'TODO: wire up' Makefile; then
```

Jeśli usuniesz `Makefile` na rzecz `justfile`, bramka na zawsze uzna projekt za
nieskonfigurowany i **evale nigdy nie odpalą — po cichu, na zielono**. Podmień w
[claude-evals.yml](.github/workflows/claude-evals.yml) nazwę pliku w tym warunku i w
`paths:` wyzwalaczy.

Najtańsza alternatywa, jeśli nie chcesz ruszać dwudziestu pięciu miejsc: zostaw
`Makefile` jako cienką przykrywkę na swój właściwy runner.

```make
check:
	just check
```

---

## Zawartość

| Ścieżka | Etap | Do czego |
|---|---|---|
| [CLAUDE.md](CLAUDE.md) | Build | Pamięć projektu: komendy, konwencje, architektura, częste błędy Claude |
| [REVIEW.md](REVIEW.md) | Deploy | Przebiegi review, próg „Important", limit nitów |
| [PROMPTS.md](PROMPTS.md) | wszystkie | Siedem promptów do skopiowania, po jednym na etap |
| [.claude/commands/](.claude/commands/) | wszystkie | `/sdlc-intent` `/sdlc-spec` `/sdlc-plan` `/sdlc-verify` `/sdlc-incident` |
| [.claude/skills/](.claude/skills/) | Design, Build, Test | Wiedza instytucjonalna, odpala się po triggerze |
| [.claude/agents/](.claude/agents/) | Build, Test | `verifier` (sprawdza, nie naprawia), `spec-reviewer` |
| [.claude/hooks/](.claude/hooks/) | Build, Deploy | Ochrona ścieżek, blokada edycji testów w TDD, bramka na produkcję |
| [docs/sdlc/](docs/sdlc/) | wszystkie | Szablony artefaktów, progi `bands.yaml`, `LESSONS.md` |
| [evals/](evals/) | Test | Zadania ewaluacyjne z kryteriami akceptacji |
| [.github/workflows/](.github/workflows/) | Test, Deploy | Review PR i evale przy zmianie `CLAUDE.md` lub `.claude/**` |

---

## Dojrzewanie: nie włączaj wszystkiego naraz

Guardraile mają rosnąć razem z projektem. Kolejność ma znaczenie, bo każdy krok opiera się
na poprzednim.

1. **Dzień 1** — `Makefile` i przycięty `CLAUDE.md`. Praca w trybie plan, commitowany `plan.md`.
2. **Tydzień 1** — hooki `protect-paths` i `format-after-edit`. Dopisuj do `CLAUDE.md` każdą
   poprawkę, którą podajesz Claude **drugi raz**.
3. **Tydzień 2+** — evale w CI (wymagają `ANTHROPIC_API_KEY` w sekretach repo), review PR
   przez agenta, `release-gate` na produkcję.
4. **Później** — tryb auto bez zatwierdzania każdej edycji i równoległe sesje na worktree
   (`claude --worktree feature-x`). Dopiero gdy wszystko powyżej działa, bo wtedy review
   przenosi się z pojedynczych edycji na artefakty.

Evale w CI pomijają się same, dopóki `Makefile` zawiera zaślepki — świeże repo nie ma czego
ewaluować, a stale czerwony check uczy zespół ignorować czerwone.

---

## Trzy zasady, o których łatwo zapomnieć

**Skill doradza, hook blokuje.** Polityka bez pokrycia w hooku albo checku na PR jest
sugestią — Claude da się z niej wyprowadzić, a w CI nie zadziała w ogóle.

**„Done" znaczy zweryfikowane.** Wklejony output `make check`, nie zdanie „powinno działać".

**Ta sama poprawka drugi raz trafia do `CLAUDE.md`, trzeci raz do hooka.** Jeśli review
wyłapuje w kółko to samo, guardrail stoi w złym miejscu.

---

## Governance dla regulowanego enterprise

Szablon zatrzymuje się na ustawieniach zespołowych w `.claude/settings.json`, które każdy
może nadpisać lokalnie. Bariery nienegocjowalne przenosi się do **managed settings** poza
repo, zarządzanych przez IT: deny-listy na sekrety i narzędzia sieciowe,
`disableBypassPermissionsMode`, `allowManagedPermissionRulesOnly`, sandbox z allowlistą
domen, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `requiredMinimumVersion`.
Szczegóły: [docs.claude.com — settings](https://docs.claude.com/en/docs/claude-code/settings).
