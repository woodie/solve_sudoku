#!/usr/bin/env ruby

class String
 def blue;  "\e[34m#{self}\e[0m" end
 def brown; "\e[33m#{self}\e[0m" end
 def reset; self.gsub(/\e\[(\d+)m/,'') end
end

puzzle = File.open('puzzle_easy.txt').readlines
puzzle.map! {|line| line.strip.gsub('.',' ') }

def render_board(puzzle)
  border = %w(+ + + +).join("---+---+---".brown)
  puts ""
  puzzle.each_with_index do |row,n|
    puts n % 3 == 0 ? border.reset : border
    row.each_char.with_index do |c,i|
      bar_color = i % 3 == 0 ? :reset : :brown
      print "| ".send(bar_color)
      print c.blue + " "
    end
    puts "|"
  end
  puts border.reset
  puts ""
end

render_board puzzle
