#!/usr/bin/env ruby

class String
  def bold;  "\e[1m#{self}\e[22m" end
  def flip;  "\e[7m#{self}\e[27m" end
  def red;   "\e[31m#{self}\e[0m" end
  def green; "\e[32m#{self}\e[0m" end
  def brown; "\e[33m#{self}\e[0m" end
  def blue;  "\e[34m#{self}\e[0m" end
  def cyan;  "\e[36m#{self}\e[0m" end
  def gray;  "\e[37m#{self}\e[0m" end
  def bgred; "\e[41m#{self}\e[0m" end
  def bgbrn; "\e[43m#{self}\e[0m" end
  def bggry; "\e[47m#{self}\e[0m" end
  def reset; self.gsub(/\e\[(\d+)m/,'') end
end

SIZE = 10
NUMS = '０１２３４５６７８９' # Special unicode
LETS = 'ａｂｃｄｅｆｇｈｉｊ' # fill-width chars

class Cell
  attr_accessor :is_mine, :reveald, :exploded, :visited, :count
  def initialize(is_mine=false)
    self.is_mine = is_mine
    self.reveald = false
    self.exploded = false
    self.visited = false
    self.count = 0
  end

  def reveal
    self.reveald = true
  end

  def explode
    self.exploded = true
  end

  def to_s
    if !reveald
      return '＇'.flip
    elsif is_mine
      return exploded ? '＊'.bgred : '＊'.flip.blue
    elsif count == 0
      return '＇'.gray
    elsif is_mine
    elsif count == 1
      return NUMS[count].bold.cyan
    elsif count == 2
      return NUMS[count].bold.green
    else
      return NUMS[count].bold.red
    end
  end
end

class Board
  attr_accessor :board
  def initialize(num_mines)
    @board = board = Array.new(SIZE) {Array.new(SIZE) {0}}
    @work = SIZE * SIZE - num_mines
    candidates = (0..((SIZE * SIZE) - 1)).to_a.shuffle.first(num_mines)
    0.upto(SIZE - 1) do |one|
      0.upto(SIZE - 1) do |two|
        comp = candidates.include?((SIZE * one) + (two % SIZE))
        board[one][two] = Cell.new(comp)
      end
    end
    0.upto(SIZE - 1) do |one|
      0.upto(SIZE - 1) do |two|
        cell = board[one][two]
        cell.count = calculate(one, two) unless cell.is_mine
      end
    end
  end

  def render
    print "\n ｀".brown
    0.upto(SIZE - 1) {|n| print LETS[n].brown}
    print "\n"
    board.each_with_index do |row,r|
      print " " + NUMS[r].brown
      row.each_with_index do |cell,c|
        print "#{cell}"
      end
      print "\n"
    end
  end

  def calculate(x, y)
    count = 0
    ([x - 1, 0].max..[x + 1, SIZE - 1].min).each do |row|
      ([y - 1, 0].max..[y + 1, SIZE - 1].min).each do |col|
        cell = @board[row][col]
        count +=1 if cell.is_mine
      end
    end
    @board[x][y].count = count
  end

  def cascade(x,y)
    cell = @board[x][y]
    cell.reveal
    cell.visited = true
    @work -= 1
    if cell.count == 0
      ([x - 1, 0].max..[x + 1, SIZE - 1].min).each do |row|
        ([y - 1, 0].max..[y + 1, SIZE - 1].min).each do |col|
          neighbor = @board[row][col]
          cascade(row, col) unless neighbor.is_mine or neighbor.visited
        end
      end
    end
  end

  def show_mines
    0.upto(SIZE - 1) do |one|
      0.upto(SIZE - 1) do |two|
        cell = board[one][two]
        cell.reveal if cell.is_mine
      end
    end
    render
  end

  def check(str)
    y = str[0].bytes.first - 97
    x = str[1].to_i
    unless (0..SIZE).include? x and (0..SIZE).include? y
      puts "\n  Invalid input."
      return
    end
    cell = @board[x][y]
    if cell.is_mine
      cell.exploded = true
      show_mines
      puts "\n You lost!"
      exit
    else
      cascade(x, y)
      if @work < 1
        show_mines
        puts "\n You won!"
        exit
      end
    end
  end
end


def play
puts "\n    💣  MINE SWEEPER 💣\n"
  myboard = Board.new(10)
  while(true)
    myboard.render
    print "\n > "
    input = gets
    myboard.check(input)
    print "\n"
  end
end

if ENV["HOME"] == "/home/coderpad"
  puts "\n  Type 'r' to get start playing."
else
  play
end
