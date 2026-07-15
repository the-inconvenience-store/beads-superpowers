#!/usr/bin/env python3
"""Validate the canonical Superbeads product-contract Markdown shape."""

from __future__ import annotations

import re
import sys
from pathlib import Path


REQUIRED_SECTIONS = (
    "Goal",
    "Source Ledger",
    "Actors and Authority",
    "Vocabulary and Domain Model",
    "Lifecycle and Invariants",
    "Journeys and States",
    "Examples and Counterexamples",
    "Outcome Trace",
    "Non-Goals and Decisions",
    "Assumptions",
    "Approval",
)
REQUIRED_TERMS = {
    "Goal": ("measurable success signal", "current workaround"),
    "Source Ledger": ("source", "status", "precedence"),
    "Actors and Authority": (
        "actor",
        "role",
        "permissions",
        "authority",
        "decision owner",
    ),
    "Vocabulary and Domain Model": ("term", "meaning", "owner"),
    "Lifecycle and Invariants": ("transition", "invariant", "side effect"),
    "Journeys and States": ("journey", "states", "recovery"),
    "Examples and Counterexamples": ("example", "counterexample"),
    "Outcome Trace": ("outcome id", "evidence"),
    "Non-Goals and Decisions": ("non-goal", "decision", "deferred"),
    "Assumptions": ("verified", "recalled", "assumed"),
    "Approval": ("status", "approved", "approver", "approved revision"),
}
UNRESOLVED = re.compile(
    r"(?i)(?:\bTBD\b|\bTODO\b|\bUNKNOWN\b|\bUNRESOLVED\b|"
    r"\bTO BE DECIDED\b|<[^>\n]+>)"
)
OUTCOME_ID = re.compile(r"\b[A-Z][A-Z0-9]*(?:-[A-Z0-9]+){2,}\b")


def fail(path: Path, section: str, reason: str) -> None:
    print(f"{path}:{section}: {reason}")


def validate_bypass(path: Path, text: str) -> bool:
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    if not lines or not lines[0].startswith("Product contract: Not applicable"):
        return False
    errors: list[str] = []
    if len(lines) != 1:
        errors.append("bypass must be one explicit statement")
    statement = lines[0].lower()
    separator = "—" if "—" in lines[0] else "--" if "--" in lines[0] else None
    if separator is None:
        errors.append("bypass must include an observed reason after a dash")
    else:
        reason = lines[0].split(separator, 1)[1].split(";", 1)[0].strip().lower()
        if len(reason) < 12 or reason in {"small change", "internal change", "small internal change"}:
            errors.append("bypass must name a concrete observed mechanical reason")
    if "; changes no " not in statement:
        errors.append("bypass must separate the observed reason from its behavior attestation")
    for boundary in (
        "user-visible behavior",
        "durable business rule",
        "workflow",
        "terminology",
        "external interface",
    ):
        if boundary not in statement:
            errors.append(f"bypass must attest no change to {boundary}")
    for reason in errors:
        fail(path, "Bypass", reason)
    return not errors


def parse_sections(text: str) -> tuple[list[str], dict[str, list[str]]]:
    order: list[str] = []
    sections: dict[str, list[str]] = {}
    current: str | None = None
    for line in text.splitlines():
        heading = re.fullmatch(r"##\s+(.+?)\s*", line)
        if heading:
            current = heading.group(1)
            order.append(current)
            sections.setdefault(current, [])
        elif current is not None:
            sections[current].append(line)
    return order, sections


def allowed_unresolved(line: str) -> bool:
    lowered = line.lower()
    owner = re.search(r"(?i)decision owner:\s*(.+)$", line)
    return (
        owner is not None and not UNRESOLVED.search(owner.group(1))
    ) or ("deferred:" in lowered and "approved by" in lowered)


def validate_contract(path: Path, text: str) -> bool:
    order, sections = parse_sections(text)
    errors: list[tuple[str, str]] = []

    for section in REQUIRED_SECTIONS:
        count = order.count(section)
        if count == 0:
            errors.append((section, "missing required heading"))
        elif count > 1:
            errors.append((section, "duplicate required heading"))
    present_required = [heading for heading in order if heading in REQUIRED_SECTIONS]
    if present_required != [s for s in REQUIRED_SECTIONS if s in sections]:
        errors.append(("Structure", "required headings are out of canonical order"))

    for section in REQUIRED_SECTIONS:
        body = "\n".join(sections.get(section, [])).strip()
        if not body:
            if section in sections:
                errors.append((section, "section is empty"))
            continue
        lowered = body.lower()
        for term in REQUIRED_TERMS[section]:
            if term not in lowered:
                errors.append((section, f"missing required field: {term}"))
        for line in sections[section]:
            if UNRESOLVED.search(line) and not allowed_unresolved(line):
                errors.append((section, f"unresolved value: {line.strip()}"))

    outcome_ids = [
        outcome_id
        for line in sections.get("Outcome Trace", [])
        for outcome_id in sorted(set(OUTCOME_ID.findall(line)))
    ]
    if not outcome_ids:
        errors.append(("Outcome Trace", "at least one stable outcome ID is required"))
    duplicates = sorted({item for item in outcome_ids if outcome_ids.count(item) > 1})
    if duplicates:
        errors.append(("Outcome Trace", f"duplicate outcome IDs: {', '.join(duplicates)}"))

    approval_body = "\n".join(sections.get("Approval", []))
    if not re.search(r"(?im)^\s*[-*]?\s*Status:\s*Approved\s*$", approval_body):
        errors.append(("Approval", "Status must be Approved"))
    approved_match = re.search(
        r"(?im)^\s*[-*]?\s*Approved revision:\s*(\S+)\s*$", approval_body
    )
    if not approved_match:
        errors.append(("Approval", "Approved revision field is required"))

    revision_match = re.search(r"(?m)^Revision:\s*(\S+)\s*$", text)
    if not revision_match:
        errors.append(("Goal", "top-level Revision field is required"))
    elif approved_match and approved_match.group(1) != revision_match.group(1):
        errors.append(("Approval", "approved revision does not match contract revision"))

    for section, reason in errors:
        fail(path, section, reason)
    return not errors


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: validate-product-contract.py CONTRACT", file=sys.stderr)
        return 2
    path = Path(sys.argv[1])
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as error:
        fail(path, "File", str(error))
        return 1
    stripped = text.lstrip()
    valid = (
        validate_bypass(path, text)
        if stripped.startswith("Product contract: Not applicable")
        else validate_contract(path, text)
    )
    return 0 if valid else 1


if __name__ == "__main__":
    raise SystemExit(main())
