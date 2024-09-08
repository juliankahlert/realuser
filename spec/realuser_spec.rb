# spec/revtree_spec.rb
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

require 'rspec'
require_relative '../lib/realuser'

RSpec.describe RealUser do
  describe RealUser::ProcFs do
    let(:pid) { 1234 }
    let(:ppid) { 5678 }
    let(:ruid) { 1000 }

    describe '.ruid' do
      it 'returns nil if the RUID cannot be determined' do
        allow(File).to receive(:stat).with("/proc/#{pid}").and_raise(Errno::ENOENT)
        expect(RealUser::ProcFs.ruid(pid)).to be_nil
      end

      it 'returns the real user ID (RUID) of a process' do
        allow(File).to receive(:stat).with("/proc/#{pid}").and_return(double(uid: ruid))
        expect(RealUser::ProcFs.ruid(pid)).to eq(ruid)
      end
    end

    describe '.ppid' do
      it 'returns nil if the PPID cannot be determined' do
        allow(File).to receive(:read).with("/proc/#{pid}/status").and_raise(Errno::ENOENT)
        expect(RealUser::ProcFs.ppid(pid)).to be_nil
      end

      it 'returns the parent process ID (PPID) of a process' do
        allow(File).to receive(:read).with("/proc/#{pid}/status").and_return("PPid:\t#{ppid}\n")
        expect(RealUser::ProcFs.ppid(pid)).to eq(ppid)
      end
    end
  end

  describe RealUser::Resolver do
    let(:pid) { 1234 }
    let(:ppid) { 5678 }
    let(:root_pid) { 10 }
    let(:ruid) { 1000 }

    describe '.deep' do
      it 'recursively resolves the root process RUID' do
        allow(RealUser::ProcFs).to receive(:ppid).with(pid).and_return(ppid)
        allow(RealUser::ProcFs).to receive(:ppid).with(ppid).and_return(root_pid)
        allow(RealUser::ProcFs).to receive(:ppid).with(root_pid).and_return(nil)
        allow(RealUser::ProcFs).to receive(:ruid).with(root_pid).and_return(ruid)

        expect(RealUser::Resolver.deep(pid)).to eq(ruid)
      end

      it 'returns the RUID of the process if no parent process exists' do
        allow(RealUser::ProcFs).to receive(:ppid).with(pid).and_return(nil)
        allow(RealUser::ProcFs).to receive(:ruid).with(pid).and_return(ruid)

        expect(RealUser::Resolver.deep(pid)).to eq(ruid)
      end
    end

    describe '.shallow' do
      it 'returns the process RUID if different from parent RUID' do
        allow(RealUser::ProcFs).to receive(:ruid).with(pid).and_return(ruid)
        allow(RealUser::ProcFs).to receive(:ppid).with(pid).and_return(ppid)
        allow(RealUser::ProcFs).to receive(:ruid).with(ppid).and_return(ruid + 1) # Different RUID

        expect(RealUser::Resolver.shallow(pid)).to eq(ruid + 1)
      end

      it 'recursively checks parent RUID until a difference is found' do
        allow(RealUser::ProcFs).to receive(:ruid).with(pid).and_return(ruid)
        allow(RealUser::ProcFs).to receive(:ppid).with(pid).and_return(ppid)
        allow(RealUser::ProcFs).to receive(:ruid).with(ppid).and_return(ruid)
        allow(RealUser::ProcFs).to receive(:ppid).with(ppid).and_return(root_pid)
        allow(RealUser::ProcFs).to receive(:ruid).with(root_pid).and_return(ruid + 1) # Different RUID

        expect(RealUser::Resolver.shallow(pid)).to eq(ruid + 1)
      end
    end
  end

  describe '.ruid' do
    let(:pid) { 1234 }
    let(:ruid) { 1000 }

    context 'when cfg is an Integer' do
      it 'calls Resolver.deep with the given PID' do
        expect(RealUser::Resolver).to receive(:deep).with(pid).and_return(ruid)
        expect(RealUser.ruid(pid)).to eq(ruid)
      end
    end

    context 'when cfg is a Hash' do
      it 'performs a deep search when :deep is true' do
        expect(RealUser::Resolver).to receive(:deep).with(pid).and_return(ruid)
        expect(RealUser.ruid(pid: pid, deep: true)).to eq(ruid)
      end

      it 'performs a shallow search when :deep is false' do
        expect(RealUser::Resolver).to receive(:shallow).with(pid).and_return(ruid)
        expect(RealUser.ruid(pid: pid, deep: false)).to eq(ruid)
      end
    end
  end
end
