require 'diffy'
include FileUtils


s1 = "hello"
s2 = "hello2"
s = Diffy::Diff.new(s1, s2)

# p FileUtils.compare_file('./diff.rb', './jsaw')

def file_diff(a, b)
    lines1 = File.readlines(a).each
    lines2 = File.readlines(b).each

    i = 1
    loop do
        puts "line #{i}: -file1, +file2" if lines1.next != lines2.next
        i += 1
    end

    loop do
        lines1.next
        puts "line #{i}: -file1"
        i += 1
    end

    loop do
        lines2.next
        puts "line #{i}: +file2"
        i += 1
    end
end

file_diff('./diff.rb', './jsaw')

# lines1 = File.readlines('./diff.rb').each { |x| p x }
