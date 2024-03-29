#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "pathname"

require_relative "../lib/database"
require_relative "../lib/entry"
require_relative "../lib/refs"
require_relative "../lib/workspace"

command = ARGV.shift

case command
when "init"
  path = ARGV.fetch(0, Dir.getwd)

  root_path = Pathname.new(File.expand_path(path))
  git_path = root_path.join(".git")

  %w[objects refs].each do |dir|
    FileUtils.mkdir_p(git_path.join(dir))
  rescue Errno::EACCES => e
    warn "fatal: #{e.message}"
    exit 1
  end

  puts "Initialized empty Jit repository in #{git_path}"
  exit 0

when "commit"
  root_path = Pathname.new(Dir.getwd)
  git_path = root_path.join(".git")
  db_path = git_path.join("objects")

  workspace = Workspace.new(root_path)
  database = Database.new(db_path)
  refs = Refs.new(git_path)

  entries = workspace.list_files.map do |file_path|
    data = workspace.read_file(file_path)
    blob = Database::Blob.new(data)

    database.store(blob)

    stat = workspace.stat_file(file_path)
    Entry.new(file_path, blob.oid, stat)
  end

  root = Database::Tree.build(entries)
  root.traverse { |tree| database.store(tree) }

  parent = refs.read_head
  name = ENV.fetch("GIT_AUTHOR_NAME")
  email = ENV.fetch("GIT_AUTHOR_EMAIL")
  author = Author.new(name, email, Time.now)
  message = $stdin.read

  commit = Database::Commit.new(parent, root.oid, author, message)
  database.store(commit)
  refs.update_head(commit.oid)

  is_root = parent.nil? ? "(root-commit) " : ""
  puts "[#{is_root}#{commit.oid}] #{message.lines.first}"
  exit 0

else
  warn "jit: '#{command}' is not a jit command."
  exit 1
end
