# frozen_string_literal: true

require_relative "lockfile"

class Refs
  LockDenied = Class.new(StandardError)

  def initialize(pathname)
    @pathname = pathname
  end

  def read_head
    return unless File.exist?(head_path)

    File.read(head_path).strip
  end

  def update_head(oid)
    lockfile = Lockfile.new(head_path)

    raise LockDenied, "Could not acquire lock on file: #{head_path}" unless lockfile.hold_for_update

    lockfile.write(oid)
    lockfile.write("\n")
    lockfile.commit
  end

  private

  def head_path
    @pathname.join("HEAD")
  end
end
