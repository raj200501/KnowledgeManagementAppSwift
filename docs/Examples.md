# Usage Examples

This document collects practical workflows you can use with the CLI.

## Example 1: Project Kickoff Notes

```bash
kmapp add --title "Project kickoff" --content "Stakeholders reviewed goals" --tags kickoff,planning
```

## Example 2: Engineering Log

```bash
kmapp add --title "CI build failure" --content "Xcode 15 regression on macOS" --tags ci,build
```

## Example 3: Research Digest

```bash
kmapp add --title "Paper summary" --content "Study on LLM guardrails" --tags research
```

## Example 4: Product Roadmap

```bash
kmapp add --title "Q3 roadmap" --content "Feature prioritization" --tags roadmap,product
```

## Example 5: Incident Notes

```bash
kmapp add --title "Incident 441" --content "Database connection spike" --tags incident,ops
```

## Example 6: Daily Journaling

```bash
kmapp add --title "Daily review" --content "Focus on release tasks" --tags journal
```

## Example 7: Meeting Summary

```bash
kmapp add --title "Team meeting" --content "Discussed onboarding" --tags meeting
```

## Example 8: Vendor Evaluation

```bash
kmapp add --title "Vendor evaluation" --content "Compared logging tools" --tags vendor,ops
```

## Example 9: Security Checklist

```bash
kmapp add --title "Security review" --content "Rotated API keys" --tags security
```

## Example 10: Release Checklist

```bash
kmapp add --title "Release checklist" --content "Validated smoke tests" --tags release
```

## Batch Ingestion

If you have a large set of notes to ingest, you can script multiple `add` calls. Example:

```bash
while read -r line; do
  title=$(echo "$line" | cut -d'|' -f1)
  content=$(echo "$line" | cut -d'|' -f2)
  kmapp add --title "$title" --content "$content" --tags bulk
 done < notes.txt
```

## Curated Output

If you want to capture just the titles for a status update, you can filter the output:

```bash
kmapp list | grep "^Title:" | sed 's/Title: //'
```

## Archiving

Export the JSON storage file and check it into a private archive repository. The JSON is already human readable and can be imported into other systems.
