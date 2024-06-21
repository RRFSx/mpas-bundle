# Function get_sha_from_yaml
# Reads a YAML file containing repository names and their corresponding SHAs
# and extracts the SHA for the given repository name.
#
# Args:
#    yaml_file: The YAML file path.
#    repository_name: The name of the repository.
#    result_var: The result variable name where the SHA will be stored.
function(get_sha_from_yaml
         yaml_file
         repository_name
         result_var
)
    # Read the YAML file content
    file(READ ${yaml_file} content)

    # Convert file content into a CMake list (where each element is one line of the file)
    string(REPLACE "\n" ";" lines "${content}")

    foreach (line ${lines})
        # Strip leading and trailing whitespace
        string(STRIP "${line}" line)

        # Skip the root key
        if (line MATCHES "^repositories:")
            continue()
        endif()

        # Match and extract SHA
        if (line MATCHES "sha: \"([^\"]*)\"")
            set(current_sha "${CMAKE_MATCH_1}")
            if (${current_repository_name} STREQUAL ${repository_name})
                set(${result_var} ${current_sha} PARENT_SCOPE)
                return()
            endif()
            continue()
        endif()

        # Match and extract repository name
        if (line MATCHES "([a-zA-Z0-9-]+):")
            set(current_repository_name "${CMAKE_MATCH_1}")
            continue()
        endif()
    endforeach()
endfunction()

# Function get_latest_commit_sha
# Fetches the SHA of the latest commit from a branch in a git repository.
#
# Args:
#    repo_url: The URL of the Git repository.
#    branch: The branch name.
#    result_var: The result variable name where the Commit SHA will be stored.
function(get_latest_commit_sha
         repo_url
         branch
         result_var
)
    # Execute the git ls-remote command
    execute_process(
            COMMAND git ls-remote ${repo_url} refs/heads/${branch}
            OUTPUT_VARIABLE git_output
            OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    string(REGEX MATCH "^[0-9a-f]+" commit_sha ${git_output})
    if (commit_sha)
        set(${result_var} ${commit_sha} PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Failed to get the latest commit SHA for ${branch} from ${repo_url}")
    endif()
endfunction()

# Function get_commit_sha_before_date
# Fetches the SHA of the latest commit from a branch in a git repository before a certain date.
#
# Args:
#    repo_url: The URL of the Git repository.
#    repo_dir: The directory where the repository will be cloned.
#    branch: The branch name.
#    before_date: The end date of the range (commits before this date will be considered).
#    result_var: The result variable name where the Commit SHA will be stored.
function(get_commit_sha_before_date
         repo_url
         repo_dir
         branch
         before_date
         result_var
)
    if (EXISTS ${repo_dir}/.git)
        # Execute git fetch --all
        execute_process(
                COMMAND git fetch --all
                WORKING_DIRECTORY ${repo_dir}
                OUTPUT_VARIABLE GIT_FETCH_OUTPUT
        )
        execute_process(
                COMMAND git checkout ${branch} 
                WORKING_DIRECTORY ${repo_dir}
		OUTPUT_VARIABLE GIT_CHECKOUT_OUTPUT
        )
    else()
        execute_process(
                COMMAND git clone ${repo_url} -b ${branch} ${repo_dir}
                RESULT_VARIABLE git_clone_result
        )
        if (NOT git_clone_result EQUAL 0)
            message(FATAL_ERROR "Failed to clone ${repo_url}")
        endif()
    endif()

    # Execute the git log command to get the latest commit before the specified date
    execute_process(
            COMMAND git log --before="${before_date}" --pretty=format:"%H" -n 1
            WORKING_DIRECTORY ${repo_dir}
            OUTPUT_VARIABLE commit_sha
            OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if (commit_sha)
        set(${result_var} ${commit_sha} PARENT_SCOPE)
    else()
        message(FATAL_ERROR "Failed to get the latest commit SHA made before ${before_date} for ${branch} from ${repo_url}")
    endif()
endfunction()

