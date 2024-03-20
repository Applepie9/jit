class Workspace
  IGNORE = [".", "..", ".git"]

  def initialize(pathname)
  @pathname = pathname
  end
  
  def list_files
  Dir.entries(@pathname) - IGNORE
  end
end