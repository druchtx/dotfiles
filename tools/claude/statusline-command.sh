#!/bin/bash

input=$(cat)

# Extract session context usage
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
max_context=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
model=$(echo "$input" | jq -r '.model.display_name')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Calculate usage
total_tokens=$((total_input + total_output))
remaining=$((max_context - total_tokens))
used_pct=$((total_tokens * 100 / max_context))

# Format numbers (K for thousands)
if [ $remaining -gt 1000 ]; then
    remaining_str="$((remaining / 1000))K"
else
    remaining_str="$remaining"
fi

# Session time
duration_sec=$((duration_ms / 1000))
duration_min=$((duration_sec / 60))
duration_hr=$((duration_min / 60))
duration_min=$((duration_min % 60))

if [ $duration_hr -gt 0 ]; then
    time_str="${duration_hr}h${duration_min}m"
else
    time_str="${duration_min}m"
fi

# Git branch
git_branch=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git -c core.useBuiltinFSMonitor=false -c core.fsmonitor=false branch --show-current 2>/dev/null)
    [ -n "$git_branch" ] && git_branch=" ($git_branch)"
fi

# Directory
short_cwd=$(echo "$cwd" | awk -F/ '{if (NF > 2) print $(NF-1)"/"$NF; else print $0}')

# Color coding
if [ $used_pct -ge 80 ]; then
    color="\033[31m"  # Red
elif [ $used_pct -ge 60 ]; then
    color="\033[33m"  # Yellow
else
    color="\033[32m"  # Green
fi

printf "%s%s | [%s] | ${color}context: %d%% (%s left), %s\033[0m\n" \
    "$short_cwd" "$git_branch" "$model" "$used_pct" "$remaining_str" "$time_str"
