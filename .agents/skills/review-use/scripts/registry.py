#!/usr/bin/env python3
"""Validate and safely evolve the review-use anti-pattern registry."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import tempfile
from datetime import date
from pathlib import Path
from typing import Any


KINDS = {"event-regex", "command-regex", "metric-threshold", "manual"}
PATTERN_FIELDS = {"id", "title", "category", "status", "description", "detector", "added", "retired"}


def load(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    validate(value)
    return value


def validate(registry: dict[str, Any]) -> None:
    if not isinstance(registry, dict) or set(registry) != {"schema_version", "patterns"}:
        raise ValueError("registry requires schema_version and patterns")
    if registry["schema_version"] != 1 or not isinstance(registry["patterns"], list):
        raise ValueError("registry schema_version must be 1 and patterns must be an array")
    ids: set[str] = set()
    for index, pattern in enumerate(registry["patterns"]):
        if not isinstance(pattern, dict) or set(pattern) != PATTERN_FIELDS:
            raise ValueError(f"patterns[{index}] fields differ")
        pattern_id = pattern["id"]
        if not isinstance(pattern_id, str) or not re.fullmatch(r"RU-AP-[0-9]{3,}", pattern_id) or pattern_id in ids:
            raise ValueError(f"patterns[{index}].id must be unique RU-AP-NNN")
        ids.add(pattern_id)
        for field in ("title", "category", "description"):
            if not isinstance(pattern[field], str) or not pattern[field].strip():
                raise ValueError(f"{pattern_id}.{field} is required")
        if pattern["status"] not in {"active", "retired"}:
            raise ValueError(f"{pattern_id}.status is invalid")
        detector = pattern["detector"]
        if not isinstance(detector, dict) or set(detector) != {"kind", "config"} or detector["kind"] not in KINDS or not isinstance(detector["config"], dict):
            raise ValueError(f"{pattern_id}.detector is invalid")
        if detector["kind"] in {"event-regex", "command-regex"}:
            expression = detector["config"].get("pattern")
            if not isinstance(expression, str):
                raise ValueError(f"{pattern_id}.detector.pattern is required")
            re.compile(expression)
        added = pattern["added"]
        if not isinstance(added, dict) or set(added) != {"review_id", "date"}:
            raise ValueError(f"{pattern_id}.added is invalid")
        date.fromisoformat(added["date"])
        if pattern["status"] == "active" and pattern["retired"] is not None:
            raise ValueError(f"{pattern_id}.retired must be null while active")
        if pattern["status"] == "retired" and not isinstance(pattern["retired"], dict):
            raise ValueError(f"{pattern_id}.retired record is required")


def atomic_write(path: Path, registry: dict[str, Any]) -> None:
    validate(registry)
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            json.dump(registry, handle, indent=2, sort_keys=True)
            handle.write("\n")
        os.replace(temporary, path)
    except BaseException:
        try:
            os.unlink(temporary)
        except FileNotFoundError:
            pass
        raise


def find_pattern(registry: dict[str, Any], pattern_id: str) -> dict[str, Any]:
    matches = [item for item in registry["patterns"] if item["id"] == pattern_id]
    if len(matches) != 1:
        raise ValueError(f"unknown pattern {pattern_id}")
    return matches[0]


def add(args: argparse.Namespace) -> None:
    registry = load(args.registry)
    if any(item["id"] == args.id for item in registry["patterns"]):
        raise ValueError(f"duplicate pattern ID {args.id}")
    config = json.loads(args.config_json)
    registry["patterns"].append({
        "id": args.id,
        "title": args.title,
        "category": args.category,
        "status": "active",
        "description": args.description,
        "detector": {"kind": args.kind, "config": config},
        "added": {"review_id": args.review_id, "date": args.date},
        "retired": None,
    })
    registry["patterns"].sort(key=lambda item: item["id"])
    atomic_write(args.registry, registry)
    print(f"added {args.id}")


def retire(args: argparse.Namespace) -> None:
    registry = load(args.registry)
    pattern = find_pattern(registry, args.id)
    if pattern["status"] != "active":
        raise ValueError(f"{args.id} is not active")
    qualifying: list[tuple[date, str]] = []
    for history_path in args.history:
        review = json.loads(history_path.read_text(encoding="utf-8"))
        if review.get("status") != "complete":
            continue
        row = next((item for item in review.get("failures", []) if item.get("pattern_id") == args.id), None)
        if row is None:
            continue
        if row.get("count", 2) > 1 or row.get("rate_per_100_sessions", 2.0) > 1.0:
            raise ValueError(f"{review.get('review_id')}: result is above near-zero")
        qualifying.append((date.fromisoformat(review["date"]), str(review["review_id"])))
    unique = {review_id: observed for observed, review_id in qualifying}
    if len(unique) < 3:
        raise ValueError("retirement requires three separate reviews")
    dates = sorted(unique.values())
    if (dates[-1] - dates[0]).days < 21:
        raise ValueError("retirement reviews must span at least 21 days")
    ordered_ids = [review_id for observed, review_id in sorted(qualifying)]
    pattern["status"] = "retired"
    pattern["retired"] = {
        "date": dates[-1].isoformat(),
        "qualifying_reviews": ordered_ids,
        "rule": "count<=1 and rate_per_100_sessions<=1 across 3+ reviews spanning 21+ days",
    }
    atomic_write(args.registry, registry)
    print(f"retired {args.id}")


def reactivate(args: argparse.Namespace) -> None:
    registry = load(args.registry)
    pattern = find_pattern(registry, args.id)
    if pattern["status"] != "retired":
        raise ValueError(f"{args.id} is not retired")
    pattern["status"] = "active"
    pattern["retired"] = None
    atomic_write(args.registry, registry)
    print(f"reactivated {args.id}")


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(description=__doc__)
    commands = root.add_subparsers(dest="command", required=True)
    validate_parser = commands.add_parser("validate")
    validate_parser.add_argument("--registry", type=Path, required=True)
    add_parser = commands.add_parser("add")
    add_parser.add_argument("--registry", type=Path, required=True)
    add_parser.add_argument("--id", required=True)
    add_parser.add_argument("--title", required=True)
    add_parser.add_argument("--category", required=True)
    add_parser.add_argument("--description", required=True)
    add_parser.add_argument("--kind", choices=sorted(KINDS), required=True)
    add_parser.add_argument("--config-json", required=True)
    add_parser.add_argument("--review-id", required=True)
    add_parser.add_argument("--date", required=True)
    retire_parser = commands.add_parser("retire")
    retire_parser.add_argument("--registry", type=Path, required=True)
    retire_parser.add_argument("--id", required=True)
    retire_parser.add_argument("--history", type=Path, action="append", required=True)
    reactivate_parser = commands.add_parser("reactivate")
    reactivate_parser.add_argument("--registry", type=Path, required=True)
    reactivate_parser.add_argument("--id", required=True)
    return root


def main() -> int:
    args = parser().parse_args()
    try:
        if args.command == "validate":
            load(args.registry)
            print(f"valid registry: {args.registry}")
        elif args.command == "add":
            add(args)
        elif args.command == "retire":
            retire(args)
        else:
            reactivate(args)
    except (OSError, ValueError, KeyError, json.JSONDecodeError, re.error) as exc:
        print(f"review-use registry error: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
