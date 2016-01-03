#!/usr/bin/env ruby

class String
  def green; "\e[32m#{self}\e[0m" end
  def cyan;  "\e[36m#{self}\e[0m" end
  def reset; self.gsub(/\e\[(\d+)m/,'') end
end

puzzle_1 = %w(6.8.....9 .576.92.1 23..5..8. .42.76...
    ......... ...94.36. .9..3..15 1.47.589. 3.....6.2)
puzzle_2 = %w(......68. ....73..9 3.9....45 49.......
    8.3.5.9.2 .......36 96....3.8 7..68.... .28......)
puzzle_3 = %w(.8....... .79..83.. ..5....9. ..73.6.59
    ...4.5... 35.9.16.. .6....2.. ..46..17. .......3.)

def board(puzzle)
  puzzle.map {|line| line.gsub('.',' ').split('').map {|x| x.to_i}}
end

def render_board(state, puzzle)
  border = %w(+ + + +).join("---+---+---".green)
  puzzle.each_with_index do |row,r|
    puts r % 3 == 0 ? border.reset : border
    row.each_char.with_index do |puz,c|
      bar_color = c % 3 == 0 ? :reset : :green
      cell = state[r][c].zero? ? ' ' : state[r][c].to_s
      cell = cell.cyan unless puz == '.'
      print "| ".send(bar_color) + "#{cell} "
    end
    puts "|"
  end
  puts border.reset
end

# https://gist.github.com/koffeinfrei/3898637

def valid?(state, x, y)
  # check in col and row
  0.upto(8) do |i|
    return false if i != y and state[x][i] == state[x][y]
    return false if i != x and state[i][y] == state[x][y]
  end
  # check in box
  x_from = (x / 3) * 3
  y_from = (y / 3) * 3
  x_from.upto(x_from + 2) do |xx|
    y_from.upto(y_from + 2) do |yy|
      return false if (xx != x or yy != y) and
          state[xx][yy] == state[x][y]
    end
  end
  true
end

def solve(state, x=0, y=0)
  $count = $count + 1
  y = 0 and x = x + 1 if y == 9
  return true if x == 9
  if state[x][y].zero?
    1.upto(9) do |i|
      state[x][y] = i
      return true if valid?(state, x, y) and
          solve(state, x, y + 1)
    end
  else
    return false unless valid?(state, x, y)
    return solve(state, x, y + 1)
  end
  state[x][y] = 0
  false
end

puzzle = puzzle_3
solution = board(puzzle)
start_time = Time.new
$count = 0
if solve(solution)
  puts "time: #{Time.now - start_time} seconds."
  puts "count: #{$count}"
  render_board(solution, puzzle)
else
  puts "Not solveable!"
end
