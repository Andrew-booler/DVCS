require 'pathname'

def os_walk(dir, ignore)
  root = Pathname(dir)
      files, dirs = [], []
      Pathname(root).find do |path|
        unless path == root
            if !path.to_s.include? ignore
              dirs << path if path.directory?
              files << path if path.file?
          end
      end
  end
  [root, dirs, files]
end

# def diff(path)
#   walk = os_walk(Dir.pwd, '.git')
#   for f in walk[2]
#     s = File.stat(f)
#     p s.mtime
#     break
#   end
# end

# x = os_walk(Dir.pwd, '.git')
# p x[1]