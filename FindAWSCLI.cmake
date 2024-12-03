# FindAWSCLI.cmake
# Locate, install, and enable downloading files from S3 using AWS CLI.
# Defines:
#  - AWSCLI_FOUND: Whether AWS CLI is found.
#  - AWSCLI_EXECUTABLE: Path to the AWS CLI executable.
#  - AWSCLI_VERSION: The version of AWS CLI.

find_program(AWSCLI_EXECUTABLE
    NAMES aws
    HINTS ENV PATH
)

if(NOT AWSCLI_EXECUTABLE)
    message(WARNING "AWS CLI not found. Attempting to install...")

    if(WIN32)
        # Windows installation
        execute_process(
            COMMAND powershell -Command "Invoke-WebRequest -Uri https://awscli.amazonaws.com/AWSCLIV2.msi -OutFile AWSCLIV2.msi; Start-Process msiexec.exe -ArgumentList '/i AWSCLIV2.msi /quiet' -NoNewWindow -Wait; Remove-Item AWSCLIV2.msi"
            RESULT_VARIABLE _install_result
        )
    else()
        # Linux or macOS installation
        execute_process(
            COMMAND sh -c "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\" && unzip awscliv2.zip && sudo ./aws/install && rm -rf awscliv2.zip aws"
            RESULT_VARIABLE _install_result
        )
    endif()

    if(_install_result EQUAL 0)
        find_program(AWSCLI_EXECUTABLE
            NAMES aws
            HINTS ENV PATH
        )
    else()
        message(FATAL_ERROR "Failed to install AWS CLI. Please install it manually.")
    endif()
endif()

if(AWSCLI_EXECUTABLE)
    # Try to get the version
    execute_process(
        COMMAND ${AWSCLI_EXECUTABLE} --version
        OUTPUT_VARIABLE _awscli_version_output
        ERROR_VARIABLE _awscli_version_error
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_STRIP_TRAILING_WHITESPACE
    )

    # Parse version (AWS CLI version format: aws-cli/x.y.z)
    string(REGEX MATCH "aws-cli/[0-9]+\\.[0-9]+\\.[0-9]+" _awscli_version_match "${_awscli_version_output}")
    if(_awscli_version_match)
        string(REPLACE "aws-cli/" "" AWSCLI_VERSION "${_awscli_version_match}")
        set(AWSCLI_FOUND TRUE)
    else()
        set(AWSCLI_FOUND FALSE)
    endif()
else()
    set(AWSCLI_FOUND FALSE)
endif()

mark_as_advanced(AWSCLI_EXECUTABLE AWSCLI_VERSION)

# Function to download files from S3
function(awscli_download_from_s3 BUCKET_NAME OBJECT_KEY LOCAL_FILE_PATH)
    if(NOT AWSCLI_EXECUTABLE)
        message(FATAL_ERROR "AWS CLI is not available. Cannot download from S3.")
    endif()

    message(STATUS "Downloading s3://${BUCKET_NAME}/${OBJECT_KEY} to ${LOCAL_FILE_PATH}")
    execute_process(
        COMMAND ${AWSCLI_EXECUTABLE} s3 cp s3://${BUCKET_NAME}/${OBJECT_KEY} ${LOCAL_FILE_PATH}
        RESULT_VARIABLE _download_result
        OUTPUT_VARIABLE _download_output
        ERROR_VARIABLE _download_error
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_STRIP_TRAILING_WHITESPACE
    )

    if(NOT _download_result EQUAL 0)
        message(FATAL_ERROR "Failed to download from S3: ${_download_error}")
    else()
        message(STATUS "Downloaded successfully: ${_download_output}")
    endif()
endfunction()
