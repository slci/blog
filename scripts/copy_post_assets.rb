# Copy _posts/<slug>/assets/** -> <dest>/assets/posts/<slug>/**
# github-pages disables _plugins/; require this file before invoking jekyll so the hook registers.

require "fileutils"

module CopyPostAssets
  module_function

  def call(source_root, dest_root)
    posts_root = File.join(source_root, "_posts")
    return unless Dir.exist?(posts_root)

    Dir.children(posts_root).each do |entry|
      next if entry.start_with?(".")

      assets_dir = File.join(posts_root, entry, "assets")
      next unless File.directory?(assets_dir)

      dest_dir = File.join(dest_root, "assets", "posts", entry)
      FileUtils.mkdir_p(dest_dir)
      FileUtils.cp_r(File.join(assets_dir, "."), dest_dir)
    end
  end
end

require "jekyll"

Jekyll::Hooks.register :site, :post_write do |site|
  CopyPostAssets.call(site.source, site.dest)
end
