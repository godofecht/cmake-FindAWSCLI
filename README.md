# FindAWSCLI.cmake

A simple CMake module to locate, install (if missing), and use AWS CLI in your CMake projects. This module also provides a handy function to download files from S3 buckets seamlessly as part of your build process.

## Features

- **Locate AWS CLI**: Automatically finds the `aws` executable on your system.
- **Install AWS CLI**: If `aws` is not found, the module attempts to install AWS CLI for you (supports Windows, macOS, and Linux).
- **S3 Downloads**: A built-in function allows you to download files from S3 buckets using AWS CLI directly within your CMake configuration.

---

## How to Use

1. Place `FindAWSCLI.cmake` in your project's `cmake/modules` folder or a shared module directory.
2. Add the module's location to `CMAKE_MODULE_PATH` in your `CMakeLists.txt`:

   ```cmake
   list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules")
   ```

3. Use `find_package` to locate AWS CLI:

   ```cmake
   find_package(AWSCLI REQUIRED)

   if(AWSCLI_FOUND)
       message(STATUS "AWS CLI found at: ${AWSCLI_EXECUTABLE}")
       message(STATUS "AWS CLI version: ${AWSCLI_VERSION}")
   else()
       message(FATAL_ERROR "AWS CLI is required but not available.")
   endif()
   ```

4. Use the `awscli_download_from_s3` function to download files from S3:

   ```cmake
   awscli_download_from_s3("your-bucket-name" "path/to/object" "${CMAKE_BINARY_DIR}/local_file")
   ```

---

## Example Workflow

Here’s a practical setup that uses the module to download a configuration file during the build:

```cmake
find_package(AWSCLI REQUIRED)

if(AWSCLI_FOUND)
    message(STATUS "AWS CLI is ready to use.")

    # Download a file from S3
    awscli_download_from_s3("example-bucket" "configs/settings.json" "${CMAKE_BINARY_DIR}/settings.json")
else()
    message(FATAL_ERROR "Cannot proceed without AWS CLI.")
endif()
```

This example:
- Locates or installs AWS CLI.
- Downloads `settings.json` from the `example-bucket` S3 bucket and saves it in the build directory.

---

## Functionality

1. **Locate**: The module uses `find_program` to detect the `aws` executable.
2. **Install**: If missing, it attempts installation using:
   - **Windows**: Installs AWS CLI via MSI using PowerShell.
   - **Linux/macOS**: Downloads and installs the CLI via a script.
3. **S3 Downloads**: A `awscli_download_from_s3` function uses `aws s3 cp` to handle downloads.

---

## Requirements

- **AWS Credentials**: Ensure your system has valid AWS credentials set up (e.g., in `~/.aws/credentials` or via environment variables).
- **Dependencies**:
  - `curl`, `unzip` (Linux/macOS)
  - `PowerShell` (Windows)

---

## Importing into your project

# Using FetchContent to Add `FindAWSCLI.cmake` to Your Project

1. Add the following to your `CMakeLists.txt`:

   ```cmake
   include(FetchContent)

   FetchContent_Declare(
       FindAWSCLI
       GIT_REPOSITORY https://github.com/your-username/cmake-find-awscli.git
       GIT_TAG main # Or a specific commit hash, branch, or tag
   )

   FetchContent_MakeAvailable(FindAWSCLI)

   list(APPEND CMAKE_MODULE_PATH ${findawscli_SOURCE_DIR})

   find_package(AWSCLI REQUIRED)

   if(AWSCLI_FOUND)
       message(STATUS "AWS CLI found at: ${AWSCLI_EXECUTABLE}")
       message(STATUS "AWS CLI version: ${AWSCLI_VERSION}")
   else()
       message(FATAL_ERROR "AWS CLI is required but not available.")
   endif()
   ```

2. Structure your repository to include `FindAWSCLI.cmake` at the root of your GitHub repository.

3. FetchContent will automatically pull the module when you configure your project.

4. Use `find_package(AWSCLI REQUIRED)` and `awscli_download_from_s3` as usual in your CMake configuration.

```
