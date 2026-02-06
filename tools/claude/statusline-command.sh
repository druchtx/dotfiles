#!/bin/bash

# ==============================================================================
# Configuration & Colors
# ==============================================================================

# ANSI color codes
readonly COLOR_CYAN='\033[36m'
readonly COLOR_GREEN='\033[32m'
readonly COLOR_YELLOW='\033[33m'
readonly COLOR_RED='\033[31m'
readonly COLOR_MAGENTA='\033[35m'
readonly COLOR_VIOLET='\033[95m'
readonly COLOR_GRAY='\033[90m'
readonly COLOR_WHITE='\033[37m'
readonly COLOR_BOLD='\033[1m'
readonly COLOR_RESET='\033[0m'

# ==============================================================================
# Helper Functions
# ==============================================================================

get_model_short_name() {
    local model_full="$1"
    local model="$model_full"
    
    if [[ "$model_full" =~ Claude[[:space:]]+(Opus|Sonnet|Haiku)[[:space:]]+([0-9.]+) ]]; then
        local model_type="${BASH_REMATCH[1]}"
        local model_version="${BASH_REMATCH[2]}"
        model="${model_type:0:1}${model_version}"
    elif [[ "$model_full" =~ Claude[[:space:]]+([0-9.]+)[[:space:]]+(Opus|Sonnet|Haiku) ]]; then
        local model_version="${BASH_REMATCH[1]}"
        local model_type="${BASH_REMATCH[2]}"
        model="${model_type:0:1}${model_version}"
    elif [[ "$model_full" =~ (Opus|Sonnet|Haiku) ]]; then
        model="${BASH_REMATCH[1]}"
    fi
    
    echo "$model"
}

format_cost() {
    local cost="$1"
    
    if [ "$cost" = "0" ]; then
        echo "\$0"
        return
    fi
    
    local cost_float
    cost_float=$(echo "$cost" | bc -l)
    
    if (( $(echo "$cost_float >= 0.01" | bc -l) )); then
        printf "\$%.2f" "$cost_float"
    else
        # Show in cents for very small amounts
        local cents
        cents=$(echo "$cost_float * 100" | bc -l)
        printf "%.1f¢" "$cents"
    fi
}

get_git_branch() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git -c core.useBuiltinFSMonitor=false -c core.fsmonitor=false branch --show-current 2>/dev/null
    fi
}

calculate_usage_pct() {
    local input_json="$1"
    local used_pct
    used_pct=$(echo "$input_json" | jq -r '.context_window.used_percentage // empty')
    
    if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
         # Cap at 100% if somehow over
        if (( $(echo "$used_pct > 100" | bc -l) )); then
            echo "100"
        else
            echo "$used_pct"
        fi
        return
    fi

    # Fallback calculation
    local total_input total_output max_context total_tokens
    total_input=$(echo "$input_json" | jq -r '.context_window.total_input_tokens // 0')
    total_output=$(echo "$input_json" | jq -r '.context_window.total_output_tokens // 0')
    max_context=$(echo "$input_json" | jq -r '.context_window.context_window_size // 200000')
    total_tokens=$((total_input + total_output))
    
    if [ "$max_context" -gt 0 ]; then
        echo "scale=1; t=$total_tokens*100/$max_context; if (t > 100) 100 else t" | bc
    else
        echo "0"
    fi
}

# ==============================================================================
# Main Logic
# ==============================================================================

main() {
    # Read all input from stdin
    local input
    input=$(cat)
    
    # 1. Parse JSON Input
    # Extract fields needed for display
    local model_full workspace_cwd project_dir cost_total session_name session_id usage_data
    
    # Use jq to extract variables roughly
    model_full=$(echo "$input" | jq -r '.model.display_name // "Claude"')
    workspace_cwd=$(echo "$input" | jq -r '.workspace.current_dir // ""')
    project_dir=$(echo "$input" | jq -r '.workspace.project_dir // ""')
    cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
    # session_id/name extraction skipped/commented out as part of hiding logic, 
    # though we might want them later. keeping parsing simple for now.

    # 2. Process Data
    local model
    model=$(get_model_short_name "$model_full")
    
    local project_name
    if [ -n "$project_dir" ]; then
        project_name=$(basename "$project_dir")
    else
        project_name=$(basename "$workspace_cwd")
    fi
    
    local git_branch
    git_branch=$(get_git_branch)
    
    local cost_str
    cost_str=$(format_cost "$cost")
    
    # Context Usage
    local used_pct
    used_pct=$(calculate_usage_pct "$input")
    local used_pct_int
    used_pct_int=$(printf "%.0f" "$used_pct")
    
    # Determine context color
    local context_color
    if [ "$used_pct_int" -lt 60 ]; then
        context_color="$COLOR_GREEN"
    elif [ "$used_pct_int" -lt 80 ]; then
        context_color="$COLOR_YELLOW"
    else
        context_color="$COLOR_RED"
    fi

    # 3. Build Output
    # Format: project/branch · model · context% · cost
    
    local output=""
    
    # Segment: Project & Branch
    output="${COLOR_CYAN}${project_name}${COLOR_RESET}"
    if [ -n "$git_branch" ]; then
        output="${output}${COLOR_GRAY}/${COLOR_RESET}${COLOR_BOLD}${COLOR_YELLOW}${git_branch}${COLOR_RESET}"
    fi
    
    # Segment: Model
    output="${output} ${COLOR_GRAY}·${COLOR_RESET} ${COLOR_BOLD}${COLOR_MAGENTA}${model}${COLOR_RESET}"
    
    # Segment: Context
    output="${output} ${COLOR_GRAY}·${COLOR_RESET} ${context_color}${used_pct_int}%${COLOR_RESET}"
    
    # Segment: Cost
    output="${output} ${COLOR_GRAY}·${COLOR_RESET} ${COLOR_YELLOW}${cost_str}${COLOR_RESET}"

    # Previous "Session" segment (Hidden)
    # output="$output ${COLOR_GRAY}·${COLOR_RESET} ${COLOR_VIOLET}${session_display}${COLOR_RESET}"
    
    printf "%b\n" "$output"
}

main
