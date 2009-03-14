# Copy html5jp JavaScript codes to public/javascripts.

dest_dir = File.join(RAILS_ROOT, 'public', 'javascripts')
FileUtils.mkdirs(dest_dir) unless File.exist?(dest_dir)

Dir.glob(File.join(RAILS_ROOT, File.dirname(__FILE__), "html5jp/html5jp/**/*.js")).each do |path|
  FileUtils.cp(path, dest_dir) unless File.exist?(File.join(dest_dir, File.basename(path)))
end
