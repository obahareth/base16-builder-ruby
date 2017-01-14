require "git"

class Base16Repository

  @@sources_filename = "sources.yaml"
  @@sources_dir = "sources"

  attr_accessor :repo_path

  def self.repo_from_sources_yaml(key:)
    yaml = YAML.load(File.read(@@sources_filename))
    url = yaml[key]
    
    return nil unless url

    repo = Base16Repository.new(path: @@sources_dir,
                                name: key,
                                url: url)

    repo.clone unless repo.exists?
    repo
  end
  
  def self.schemes_repo
    repo_from_sources_yaml(key: "schemes")
  end

  def self.templates_repo
    repo_from_sources_yaml(key: "templates")
  end

  def initialize(path:, name:, url:)
    @path = path
    @name = name
    @url = url

    @repo_path = "#{@path}/#{@name}"
  end

  def update
    if exists?
      repo = Git.open(@repo_path)
      repo.pull
    else
      clone
    end
  end

  def clone
    Git.clone(@url, @name, path: @path)
  end

  def exists?
    Dir.exists?(@repo_path)
  end

  def is_scheme_list_repo?
    @repo_path == "sources/schemes"
  end

  def is_template_list_repo?
    @repo_path == "sources/templates"
  end

  def scheme_repo_urls
    return nil unless exists? && is_scheme_list_repo?
    YAML.load(File.read("#{@repo_path}/list.yaml"))
  end

  def template_repo_urls
    return nil unless exists? && is_template_list_repo?
    YAML.load(File.read("#{@repo_path}/list.yaml"))
  end
end