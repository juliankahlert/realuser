# lib/realuser.rb
#
# MIT License
#
# Copyright (c) 2024 Julian Kahlert
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module RealUser

  # The `ProcFs` class interacts with the `/proc` filesystem to fetch
  # information about the real user ID (RUID) and parent process ID (PPID) of a given process.
  class ProcFs

    # Retrieves the real user ID (RUID) of the process specified by `pid`.
    # Defaults to the current process ID if none is provided.
    #
    # @param pid [Integer] the process ID for which to retrieve the RUID. Defaults to `Process.pid`.
    # @return [Integer, nil] the real user ID of the process, or `nil` if it cannot be determined.
    def self.ruid(pid = Process.pid)
      @ruid_cache ||= {}
      key = pid.to_s.to_sym

      result = @ruid_cache[key]
      return result if result

      result = File.stat("/proc/#{pid}").uid
      @ruid_cache[key] = result
      result
    rescue
      @ruid_cache[key] = nil
      nil
    end

    # Retrieves the parent process ID (PPID) of the process specified by `pid`.
    # Defaults to the current process ID if none is provided.
    #
    # @param pid [Integer] the process ID for which to retrieve the PPID. Defaults to `Process.pid`.
    # @return [Integer, nil] the parent process ID of the process, or `nil` if it cannot be determined.
    def self.ppid(pid = Process.pid)
      @ppid_cache ||= {}
      key = pid.to_s.to_sym

      result = @ppid_cache[key]
      return result if result

      result = File.read("/proc/#{pid}/status").match(/^PPid:\s+(\d+)/)[1].to_i
      @ppid_cache[key] = result
      result
    rescue
      @ppid_cache[key] = nil
      nil
    end
  end

  # The `Resolver` class provides methods to resolve the real user ID (RUID) of a process
  # and its parent processes, either through a deep search (resolving the root RUID) or a shallow search.
  class Resolver

    # Resolves the real user ID (RUID) of the root process ancestor of the given `pid`.
    # It recursively traverses the parent processes until it finds the root process.
    #
    # @param pid [Integer] the process ID for which to resolve the root RUID.
    # @return [Integer, nil] the root RUID of the process, or `nil` if it cannot be determined.
    def self.deep(pid)
      ppid = ProcFs.ppid(pid)

      # has parent and parent is not init
      if ppid && ppid > 1
        deep(ppid)
      else
        ProcFs.ruid(pid)
      end
    end

    # Resolves the real user ID (RUID) of the given `pid` or its nearest ancestor where
    # the RUID differs from the process's parent RUID.
    #
    # @param pid [Integer] the process ID for which to resolve the shallow RUID.
    # @param pruid [Integer, nil] the parent process's RUID. Used to compare and stop if a difference is found.
    # @return [Integer, nil] the RUID of the process or the nearest ancestor with a different RUID.
    def self.shallow(pid, pruid = nil)
      ruid = ProcFs.ruid(pid)
      return ruid if pruid && (ruid != pruid || ruid.nil?)

      ppid = ProcFs.ppid(pid)

      # has parent and parent is not init
      if ppid && ppid > 1
        shallow(ppid, ruid)
      else
        ruid
      end
    end
  end

  # Determines the real user ID (RUID) of a process, either using a deep or shallow search.
  # If a `Hash` is provided, the configuration specifies whether to perform a deep search.
  #
  # @param cfg [Integer, Hash] the process ID (Integer) or configuration Hash.
  #   - If an Integer is provided, a deep search is performed.
  #   - If a Hash is provided, it can contain:
  #     - `:pid` (Integer): the process ID to resolve. Defaults to the current process.
  #     - `:deep` (Boolean): whether to perform a deep search. Defaults to shallow.
  # @return [Integer, nil] the real user ID of the process, or `nil` if it cannot be determined.
  def self.ruid(cfg = Process.pid)
    case cfg
    when Integer
      Resolver.deep(cfg)
    when Hash
      pid = cfg[:pid] || Process.pid
      deep = cfg[:deep]
      return Resolver.deep(pid) if deep

      Resolver.shallow(pid)
    end
  end
end
