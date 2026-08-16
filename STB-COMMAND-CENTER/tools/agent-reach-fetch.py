#!/usr/bin/env python3
"""
STB Command Center — Agent-Reach Signal Fetcher
Layer: tools/ (mechanical work, no AI needed)

Run weekly before starting a new build sprint or content cycle.
Drops signal files into _config/signals/ as Layer 3 reference.

Usage:
    python3 tools/agent-reach-fetch.py

Requires: Agent-Reach installed
    pipx install https://github.com/Panniantong/agent-reach/archive/main.zip
    agent-reach install --env=auto
"""

import subprocess
import json
import os
from datetime import datetime

SIGNALS_DIR = "_config/signals"
DATE_STR = datetime.now().strftime("%Y-%m-%d")

KEYWORDS = [
    "burnout healer coach",
    "overloaded practitioner",
    "coaching offer unclear",
    "systems for coaches",
    "breathwork business",
    "nervous system regulation business",
    "stability seeker founder",
]

REDDIT_SUBS = [
    "coachingbusiness",
    "solopreneur",
    "smallbusiness",
    "breathwork",
]


def fetch_twitter_signals():
    """Fetch Twitter/X signal threads for STB keywords."""
    results = []
    for keyword in KEYWORDS[:3]:  # limit to avoid rate limits
        try:
            result = subprocess.run(
                ["twitter", "search", keyword, "--limit", "10", "--json"],
                capture_output=True, text=True, timeout=30
            )
            if result.returncode == 0:
                results.append({
                    "keyword": keyword,
                    "source": "twitter",
                    "data": json.loads(result.stdout) if result.stdout else []
                })
        except Exception as e:
            print(f"Twitter fetch failed for '{keyword}': {e}")
    return results


def fetch_reddit_signals():
    """Fetch Reddit signal threads from coaching/solopreneur subs."""
    results = []
    for sub in REDDIT_SUBS:
        try:
            result = subprocess.run(
                ["rdt-cli", "hot", sub, "--limit", "5", "--json"],
                capture_output=True, text=True, timeout=30
            )
            if result.returncode == 0:
                results.append({
                    "subreddit": sub,
                    "source": "reddit",
                    "data": json.loads(result.stdout) if result.stdout else []
                })
        except Exception as e:
            print(f"Reddit fetch failed for r/{sub}: {e}")
    return results


def write_signal_file(signals, source):
    """Write signals to Layer 3 reference file."""
    os.makedirs(SIGNALS_DIR, exist_ok=True)
    filename = f"{SIGNALS_DIR}/{DATE_STR}-{source}-signals.json"
    with open(filename, "w") as f:
        json.dump({
            "fetched_at": DATE_STR,
            "source": source,
            "signals": signals
        }, f, indent=2)
    print(f"Signals written to {filename}")
    return filename


def write_signal_summary(twitter_signals, reddit_signals):
    """Write human-readable summary for Claude Code to load as L3 reference."""
    summary_path = f"{SIGNALS_DIR}/LATEST-SIGNAL-SUMMARY.md"
    with open(summary_path, "w") as f:
        f.write(f"# STB Signal Intelligence Summary\n")
        f.write(f"**Fetched:** {DATE_STR} via Agent-Reach\n\n")
        f.write("Use this file as Layer 3 reference when generating AI suggestions ")
        f.write("or planning carousel content.\n\n")
        f.write("---\n\n")
        f.write("## Twitter/X Signals\n\n")
        for signal in twitter_signals:
            f.write(f"**Keyword:** `{signal['keyword']}`\n")
            if signal.get('data'):
                f.write(f"- {len(signal['data'])} threads found\n")
            f.write("\n")
        f.write("## Reddit Signals\n\n")
        for signal in reddit_signals:
            f.write(f"**r/{signal['subreddit']}**\n")
            if signal.get('data'):
                f.write(f"- {len(signal['data'])} hot posts found\n")
            f.write("\n")
        f.write("---\n\n")
        f.write("*Full JSON data in dated signal files in this directory.*\n")
    print(f"Summary written to {summary_path}")


if __name__ == "__main__":
    print("STB Command Center — Agent-Reach Signal Fetch")
    print(f"Date: {DATE_STR}")
    print("=" * 50)

    print("\nFetching Twitter signals...")
    twitter_signals = fetch_twitter_signals()
    if twitter_signals:
        write_signal_file(twitter_signals, "twitter")

    print("\nFetching Reddit signals...")
    reddit_signals = fetch_reddit_signals()
    if reddit_signals:
        write_signal_file(reddit_signals, "reddit")

    print("\nWriting summary...")
    write_signal_summary(twitter_signals, reddit_signals)

    print("\nDone. Load _config/signals/LATEST-SIGNAL-SUMMARY.md as L3 reference.")
