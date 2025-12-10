#!/bin/bash
# Space Engineers Configuration Helper
# Auto-discovers config schema and applies environment variable overrides

# Convert environment variable name to XML element name and path
# Example: SERVER_NAME -> ServerName (root level)
#          SESSION_MAX_PLAYERS -> MaxPlayers (SessionSettings level)
env_to_xml_element() {
    local env_var="$1"
    
    # Remove SE_ prefix if present
    env_var="${env_var#SE_}"
    
    # Check if this is a SessionSettings variable
    local xml_path="/MyConfigDedicated"
    if [[ "$env_var" =~ ^SESSION_ ]]; then
        xml_path="/MyConfigDedicated/SessionSettings"
        # Remove SESSION_ prefix for element name
        env_var="${env_var#SESSION_}"
    fi
    
    # Convert SCREAMING_SNAKE_CASE to PascalCase
    # SERVER_NAME -> ServerName
    # MAX_PLAYERS -> MaxPlayers
    local xml_element=$(echo "$env_var" | awk -F_ '{
        result = ""
        for(i=1; i<=NF; i++) {
            result = result toupper(substr($i,1,1)) tolower(substr($i,2))
        }
        print result
    }')
    
    echo "${xml_path}/${xml_element}"
}

# Get all valid XML elements from SE config (both root and SessionSettings)
get_valid_elements() {
    local config_file="$1"
    
    if [ ! -f "$config_file" ]; then
        echo ""
        return 1
    fi
    
    # Get root-level elements
    xmlstarlet sel -t -m "/MyConfigDedicated/*[not(self::SessionSettings)]" -v "name()" -n "$config_file" 2>/dev/null | tr '\n' ' '
    # Get SessionSettings elements with SESSION_ prefix
    xmlstarlet sel -t -m "/MyConfigDedicated/SessionSettings/*" -v "concat('SESSION_', name())" -n "$config_file" 2>/dev/null | tr '\n' ' '
}

# Update a single config value with validation
update_config_value() {
    local config_file="$1"
    local xml_path="$2"
    local new_value="$3"
    local env_var_name="$4"
    
    # Check if element exists in config
    if xmlstarlet sel -t -v "$xml_path" "$config_file" &>/dev/null; then
        # Element exists, update it
        xmlstarlet ed -L -u "$xml_path" -v "$new_value" "$config_file" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "  ✓ ${env_var_name} → ${xml_path} = ${new_value}"
            return 0
        else
            echo "  ✗ ${env_var_name}: Failed to update ${xml_path}"
            return 1
        fi
    else
        echo "  ⚠ ${env_var_name}: Element '${xml_path}' not found in config"
        return 1
    fi
}

# Find similar element names (fuzzy match for suggestions)
find_similar_elements() {
    local search_term="$1"
    local valid_elements="$2"
    
    # Get first 4 chars for fuzzy matching
    local prefix="${search_term:0:4}"
    
    echo "$valid_elements" | tr ' ' '\n' | grep -i "^${prefix}" | head -3 | tr '\n' ' '
}

# Apply environment variable overrides to config
apply_environment_overrides() {
    local config_file="$1"
    
    if [ ! -f "$config_file" ]; then
        echo "ERROR: Config file not found: $config_file"
        return 1
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Applying Environment Variable Overrides"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Get valid elements from current SE config
    local valid_elements=$(get_valid_elements "$config_file")
    
    if [ -z "$valid_elements" ]; then
        echo "WARNING: Could not parse config file structure"
        return 1
    fi
    
    local applied_count=0
    local skipped_count=0
    
    # Process SE_ prefixed environment variables
    while IFS='=' read -r env_var env_value; do
        # Skip if empty or not SE_ prefixed
        if [[ ! "$env_var" =~ ^SE_ ]]; then
            continue
        fi
        
        # Convert env var to XML path
        local xml_path=$(env_to_xml_element "$env_var")
        
        # Check if element exists and update
        if update_config_value "$config_file" "$xml_path" "$env_value" "$env_var"; then
            ((applied_count++))
        else
            ((skipped_count++))
            
            # Suggest similar elements
            local xml_element=$(basename "$xml_path")
            local similar=$(find_similar_elements "$xml_element" "$valid_elements")
            if [ -n "$similar" ]; then
                echo "    Suggestion: Did you mean one of these? $similar"
            fi
        fi
    done < <(env | grep '^SE_')
    
    echo ""
    echo "Summary: ${applied_count} applied, ${skipped_count} skipped"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    return 0
}

# Initialize config from SE default if user doesn't have one
initialize_config() {
    local default_config="$1"
    local user_config="$2"
    local force_update="${3:-false}"
    
    # If user config doesn't exist, copy from SE default
    if [ ! -f "$user_config" ]; then
        echo "No config found at: $user_config"
        
        if [ -f "$default_config" ]; then
            echo "Copying default config from SE installation..."
            mkdir -p "$(dirname "$user_config")"
            cp "$default_config" "$user_config"
            echo "✓ Config initialized from: $default_config"
            return 0
        else
            echo "ERROR: Default config not found at: $default_config"
            return 1
        fi
    fi
    
    # Check if SE's default is newer (SE was updated)
    if [ "$force_update" != "true" ] && [ -f "$default_config" ] && [ "$default_config" -nt "$user_config" ]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "⚠ NOTICE: Space Engineers Update Detected"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "SE's default config is newer than your config file."
        echo "Your config: $user_config"
        echo "New default: $default_config"
        echo ""
        echo "Set AUTO_UPDATE_CONFIG=true to automatically update."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
    fi
    
    # Auto-update if requested
    if [ "$force_update" = "true" ] && [ -f "$default_config" ]; then
        local backup_file="${user_config}.backup.$(date +%Y%m%d-%H%M%S)"
        echo "Backing up current config to: $backup_file"
        cp "$user_config" "$backup_file"
        
        echo "Updating config from SE default..."
        cp "$default_config" "$user_config"
        echo "✓ Config updated! Backup saved."
    fi
    
    return 0
}

# Display available configuration options
show_available_config() {
    local config_file="$1"
    
    if [ ! -f "$config_file" ]; then
        echo "Config file not found: $config_file"
        return 1
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Available Configuration Options"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    echo "Root-level settings:"
    xmlstarlet sel -t -m "/MyConfigDedicated/*[not(self::SessionSettings)]" \
        -v "name()" -o " = " -v "." -n "$config_file" 2>/dev/null | \
        while IFS='=' read -r element value; do
            # Convert to env var style
            local env_var=$(echo "$element" | sed 's/\([A-Z]\)/_\1/g' | tr '[:lower:]' '[:upper:]' | sed 's/^_//')
            printf "  SE_%-40s (current: %s)\n" "$env_var" "$(echo $value | xargs)"
        done
    
    echo ""
    echo "SessionSettings:"
    xmlstarlet sel -t -m "/MyConfigDedicated/SessionSettings/*" \
        -v "name()" -o " = " -v "." -n "$config_file" 2>/dev/null | \
        while IFS='=' read -r element value; do
            # Convert to env var style with SESSION_ prefix
            local env_var=$(echo "$element" | sed 's/\([A-Z]\)/_\1/g' | tr '[:lower:]' '[:upper:]' | sed 's/^_//')
            printf "  SE_SESSION_%-40s (current: %s)\n" "$env_var" "$(echo $value | xargs)"
        done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Export functions for use in other scripts
export -f env_to_xml_element
export -f get_valid_elements
export -f update_config_value
export -f find_similar_elements
export -f apply_environment_overrides
export -f initialize_config
export -f show_available_config
