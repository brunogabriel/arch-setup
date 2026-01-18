#!/bin/bash

# core/logger.sh
# Logging system for arch-setup CLI

# Initialize log file
init_logger() {
    if [ "$ENABLE_LOGGING" = true ]; then
        # Create config directory if it doesn't exist
        mkdir -p "$CONFIG_DIR" 2>/dev/null || {
            gum style --foreground 214 "⚠ Warning: Could not create config directory at $CONFIG_DIR"
            return 1
        }
        
        # Create log file if it doesn't exist
        touch "$LOG_FILE" 2>/dev/null || {
            gum style --foreground 214 "⚠ Warning: Could not create log file at $LOG_FILE"
            return 1
        }
        
        # Add session separator
        echo "" >> "$LOG_FILE"
        echo "========================================" >> "$LOG_FILE"
        echo "Session started: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
        echo "========================================" >> "$LOG_FILE"
    fi
}

# Log a message
# Args:
#   $1 - log level (INFO, SUCCESS, WARNING, ERROR)
#   $2 - message
log_message() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ "$ENABLE_LOGGING" = true ]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null
    fi
}

# Log info message
log_info() {
    log_message "INFO" "$*"
}

# Log success message
log_success() {
    log_message "SUCCESS" "$*"
}

# Log warning message
log_warning() {
    log_message "WARNING" "$*"
}

# Log error message
log_error() {
    log_message "ERROR" "$*"
}

# Log command execution
# Args:
#   $1 - command description
#   $2 - command to execute
# Returns:
#   command exit code
log_command() {
    local description=$1
    local command=$2
    
    log_info "Executing: $description"
    log_info "Command: $command"
    
    # Execute command and capture output
    local output
    local exit_code
    
    if output=$(eval "$command" 2>&1); then
        exit_code=0
        log_success "$description - SUCCESS"
        if [ -n "$output" ]; then
            log_info "Output: $output"
        fi
    else
        exit_code=$?
        log_error "$description - FAILED (exit code: $exit_code)"
        if [ -n "$output" ]; then
            log_error "Output: $output"
        fi
    fi
    
    return $exit_code
}

# View log file
view_logs() {
    if [ ! -f "$LOG_FILE" ]; then
        gum style --foreground 214 "⚠ No log file found at $LOG_FILE"
        return 1
    fi
    
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Log File: $LOG_FILE"
    
    echo ""
    
    # Show last 50 lines of log
    tail -n 50 "$LOG_FILE"
    
    echo ""
    gum style --foreground 81 "Showing last 50 lines. Full log: $LOG_FILE"
}

# Clear log file
clear_logs() {
    if gum confirm "Clear all logs?"; then
        > "$LOG_FILE"
        log_info "Log file cleared by user"
        gum style --foreground 48 "✓ Logs cleared"
    fi
}
