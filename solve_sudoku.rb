#!/usr/bin/env ruby

require 'colorize'


puzzle = File.open('puzzle_easy.txt').readlines
puzzle.map! {|line| line.strip.gsub('.',' ') }

def render_board(puzzle)
  border = %w(+ + + +).join("---+---+---".yellow)
  puts ""
  puzzle.each_with_index do |row,n|
    puts n % 3 == 0 ? border.black : border
    row.each_char.with_index do |c,i|
      bar_color = i % 3 == 0 ? :black : :yellow
      print "| ".colorize(bar_color)
      print c.blue + " "
    end
    puts "|".black
  end
  puts border.black
  puts ""
end

render_board puzzle
