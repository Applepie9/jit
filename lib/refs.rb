# frozen_string_literal: true

require_relative "lockfile"

class Refs
  def initialize(pathname)
    @pathname = pathname
  end

  def read_head
    return unless File.exist?(head_path)

    File.read(head_path).strip
  end

  def update_head(oid)
    lockfile = Lockfile.new(head_path)

    lockfile.write(oid)
    lockfile.write("\n")
    lockfile.commit
  end

  private

  def head_path
    @pathname.join("HEAD")
  end
end
