# RealUser

[![Build Status](https://github.com/juliankahlert/realuser/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/juliankahlert/realuser)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/t/juliankahlert/realuser)](https://github.com/juliankahlert/realuser/commits/)
[![GitHub Tag](https://img.shields.io/github/v/tag/juliankahlert/realuser)](https://github.com/juliankahlert/realuser)
[![Gem Version](https://img.shields.io/gem/v/realuser)](https://rubygems.org/gems/realuser)

## Introduction

The `RealUser` gem provides a simple Ruby interface for retrieving the real user ID (RUID) of a process and its parent processes on Linux systems. It interacts with the `/proc` filesystem to fetch detailed process information and supports both deep and shallow resolution of the RUID.

## Features

- **Retrieve RUID**: Obtain the real user ID of a specific process.
- **Parent Process Lookup**: Access the RUID of a process’s parent and ancestor processes.
- **Deep and Shallow Resolution**: Choose between deep resolution (finding the root process) or shallow resolution (finding the nearest ancestor with a different RUID).
- **Caching**: Efficiently caches results to improve performance.

## Install

The supported installation methods are:

### Using `gitpack`

To install the gem from RubyGems:

```sh
gitpack add juliankahlert/realuser
```

### Using `gem`

To install the gem from RubyGems:

```sh
gem install realuser
```

### From Source

You can also install the gem from the source repository:

```sh
git clone https://github.com/juliankahlert/realuser.git
cd realuser
gem build realuser.gemspec
sudo gem install --local realuser-0.1.0.gem
```

## API Documentation

### `RealUser#ruid(cfg = Process.pid)`

- **Description**: Determines the RUID of a process based on the provided configuration. Can perform deep or shallow resolution based on the options given.
- **Parameters**:
  - `cfg` (Integer, Hash): 
    - If an Integer, it performs a deep resolution for the given `pid`.
    - If a Hash, it can contain:
      - `:pid` (Integer): The process ID to resolve. Defaults to the current process.
      - `:deep` (Boolean): If `true`, performs a deep resolution; if `false` or omitted, performs a shallow resolution.
- **Returns**: Integer representing the RUID of the process, or `nil` if it cannot be determined.

### `RealUser::Resolver`

- **`.deep(pid)`**
  - **Description**: Recursively resolves and returns the RUID of the root process ancestor of the specified `pid`.
  - **Parameters**:
    - `pid` (Integer): The process ID to start the resolution from.
  - **Returns**: Integer representing the RUID of the root ancestor, or `nil` if the RUID cannot be determined.

- **`.shallow(pid, pruid = nil)`**
  - **Description**: Resolves and returns the RUID of the given `pid` or the nearest ancestor where the RUID differs from `pruid`. Recursively checks parent processes if needed.
  - **Parameters**:
    - `pid` (Integer): The process ID to start the resolution from.
    - `pruid` (Integer, optional): The RUID of the parent process to compare against. If provided, will return the RUID of the process if it differs from `pruid`.
  - **Returns**: Integer representing the RUID of the nearest ancestor with a different RUID, or the RUID of the specified process.

### `RealUser::ProcFs`

- **`.ruid(pid = Process.pid)`**
  - **Description**: Retrieves the real user ID (RUID) of the process with the specified `pid`. Defaults to the current process ID if `pid` is not provided.
  - **Parameters**:
    - `pid` (Integer): The process ID to retrieve the RUID for. Defaults to `Process.pid`.
  - **Returns**: Integer representing the RUID, or `nil` if the RUID cannot be determined.

- **`.ppid(pid = Process.pid)`**
  - **Description**: Retrieves the parent process ID (PPID) of the process with the specified `pid`. Defaults to the current process ID if `pid` is not provided.
  - **Parameters**:
    - `pid` (Integer): The process ID to retrieve the PPID for. Defaults to `Process.pid`.
  - **Returns**: Integer representing the PPID, or `nil` if the PPID cannot be determined.

For detailed API documentation, please refer to the [YARD documentation](https://rubydoc.info/github/juliankahlert/realuser).

## Example Usage

Here is an example of how to use the `RealUser` gem to find the RUID of a process and its parent processes:

```ruby
require 'realuser'

# Create an instance of the RealUser module
real_user = RealUser.new

# Get the RUID of the current process
puts "Current process RUID: #{real_user.ruid}"

# Get the RUID of a specific process (PID 1234)
puts "Process 1234 RUID: #{real_user.ruid(1234)}"

# Perform a deep resolution to find the root RUID of a specific process (PID 1234)
puts "Root RUID of process 1234: #{real_user.ruid(pid: 1234, deep: true)}"

# Perform a shallow resolution to find the nearest ancestor with a different RUID
puts "Shallow RUID of process 1234: #{real_user.ruid(pid: 1234, deep: false)}"
```

## Encouragement for Contribution

Contributions from the community are welcome! If you find any issues, have suggestions for improvements, or want to add new features, please feel free to submit a pull request or open an issue on [GitHub](https://github.com/juliankahlert/realuser).

## License

`RealUser` is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
