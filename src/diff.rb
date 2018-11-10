require 'diff/lcs'

# Example usage
#
# p textdiff("aa\nbb\n", "bb\naa\n") # produces [[["-", 0, "aa\n"]], [["+", 1, "aa\n"]]]
# p patch("aa\nbb\n", textdiff("aa\nbb\n", "bb\naa\n")) # produces ["bb\n", "aa\n"]
#
# include this in other files with `require_relative 'diff.rb'`

def linesplit(str)
    str.lines
end

def textdiff(prev_str, new_str)
    return Diff::LCS.diff(linesplit(prev_str), linesplit(new_str))
end

def patch(prev_str, diffs)
    return Diff::LCS.patch!(linesplit(prev_str), diffs)
end
