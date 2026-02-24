"""Tests for daynote carryover logic."""

import importlib.machinery
import importlib.util
import sys
from pathlib import Path

# Import from the daynote script (no .py extension)
_script = Path(__file__).parent.parent / "home" / "dot-local" / "bin" / "daynote"
_loader = importlib.machinery.SourceFileLoader("daynote", str(_script))
spec = importlib.util.spec_from_loader("daynote", _loader)
daynote = importlib.util.module_from_spec(spec)
sys.modules["daynote"] = daynote
spec.loader.exec_module(daynote)


PREVIOUS_NOTE = """\
# Monday

## Carried over

- [ ] discuss iam constraint rollback
- [x] Restorer: test run on staging
- [x] Restorer: work out how to access staging database

## AM

### Anon Restore

- [x] Get truncate Kombo merged
- [x] Manually run anon
- [x] Re-run restore and check over it
- [x] Run restore in anger?
- [ ] Restorer: look over, do testing, code review
- [ ] Parameter handling TF PR

### Website OOM

- [x] Redis OOM Cloudwatch Alarm PR
- [ ] Redis OOM: Don't store results PR
- [ ] Redis OOM: Redis->SQS discuss
- [ ] Check on CF ticket
- [x] Reinstate JA4 rules

### Tailscale install

- [ ] Tailscale request Kaizen

### Snapshot deletion

- [x] Get infra PR merged
- [ ] Get application PR merged
- [ ] Run manual tagging script

### Interview End

- [x] Kick off planning run
- [ ] Interview end: check in on result
- [ ] Serialisation bug fix PR

### Agent Inbox

- [x] Plan out
- [x] First version
- [ ] Agent inbox refinements

## PM

- [ ] London travel: book trains
"""

EXPECTED_OUTPUT = """\
# Tuesday

## Carried over

- [ ] discuss iam constraint rollback

## AM

- [ ] Restorer: look over, do testing, code review
- [ ] Parameter handling TF PR
- [ ] Redis OOM: Don't store results PR
- [ ] Redis OOM: Redis->SQS discuss
- [ ] Check on CF ticket
- [ ] Tailscale request Kaizen
- [ ] Get application PR merged
- [ ] Run manual tagging script
- [ ] Interview end: check in on result
- [ ] Serialisation bug fix PR
- [ ] Agent inbox refinements

## PM

- [ ] London travel: book trains
"""


def test_extract_carryover():
    sections = daynote.extract_carryover(PREVIOUS_NOTE)

    assert len(sections) == 3

    assert sections[0][0] == "## Carried over"
    assert sections[0][1] == ["- [ ] discuss iam constraint rollback"]

    assert sections[1][0] == "## AM"
    assert len(sections[1][1]) == 11

    assert sections[2][0] == "## PM"
    assert sections[2][1] == ["- [ ] London travel: book trains"]


def test_build_note():
    sections = daynote.extract_carryover(PREVIOUS_NOTE)
    result = daynote.build_note("Tuesday", sections)
    assert result == EXPECTED_OUTPUT


def test_empty_note():
    sections = daynote.extract_carryover("# Friday\n\n## AM\n\n- [x] All done\n\n## PM\n")
    assert sections == []


def test_build_note_no_carryover():
    result = daynote.build_note("Wednesday", [])
    assert result == "# Wednesday\n"


def test_all_sections_completed():
    content = """\
# Thursday

## Planning

- [x] Sprint review
- [x] Backlog grooming

## Development

- [x] Ship feature
"""
    sections = daynote.extract_carryover(content)
    assert sections == []
