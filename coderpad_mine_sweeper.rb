#!/usr/bin/env ruby

NUMS = '０１２３４５６７８９ＡＢＣＤＥＦ' # FULLWIDTH LATIN
LETS = 'ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐ' # SMALL LETTERS
CPAD = ENV["HOME"] == "/home/coderpad"
TILE = CPAD ? '⃞' : '＇'
SIZE = 16

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
end

class Cell
  attr_accessor :is_mine, :revealed, :exploded, :count
  def initialize(is_mine=false)
    self.is_mine = is_mine
    self.revealed = false
    self.exploded = false
    self.count = 0
  end

  def to_s
    if !revealed
      return TILE.flip
    elsif is_mine
      return exploded ? '＊'.bgred : '＊'.flip.blue
    elsif count == 0
      return TILE.gray
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
  def initialize(num_mines=SIZE)
    @board = Array.new(SIZE) {Array.new(SIZE) {0}}
    @to_do = SIZE * SIZE - num_mines
    candidates = (0..((SIZE * SIZE) - 1)).to_a.shuffle.first(num_mines)
    0.upto(SIZE - 1) do |one|
      0.upto(SIZE - 1) do |two|
        comp = candidates.include?((SIZE * one) + (two % SIZE))
        @board[one][two] = Cell.new(comp)
      end
    end
    0.upto(SIZE - 1) do |one|
      0.upto(SIZE - 1) do |two|
        cell = @board[one][two]
        cell.count = calculate(one, two) unless cell.is_mine
      end
    end
  end

  def render
    puts "\e[H\e[2J"
    puts "\n   💣 MINE SWEEPER\n"
    print "\n ｀".brown
    0.upto(SIZE - 1) {|n| print LETS[n].brown}
    print "\n"
    @board.each_with_index do |row,r|
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
    cell.revealed = true
    @to_do -= 1
    if cell.count == 0
      ([x - 1, 0].max..[x + 1, SIZE - 1].min).each do |row|
        ([y - 1, 0].max..[y + 1, SIZE - 1].min).each do |col|
          neighbor = @board[row][col]
          cascade(row, col) unless neighbor.is_mine or neighbor.revealed
        end
      end
    end
  end

  def show_mines
    0.upto(SIZE - 1) do |one|
      0.upto(SIZE - 1) do |two|
        cell = @board[one][two]
        cell.revealed = true if cell.is_mine
      end
    end
    render
  end

  def check(str)
    y = str[0].bytes.first - 97
    x = str[1].bytes.first - 55
    x +=7 if x < 10
    unless (0..SIZE).include? x and (0..SIZE).include? y
      puts "\n  Invalid input.\n"
      sleep(2)
      return
    end
    cell = @board[x][y]
    if cell.is_mine
      cell.exploded = true
      show_mines
      puts "\n You lost!\n"
      sleep(3) if CPAD
      exit
    else
      cascade(x, y)
      if @to_do < 1
        show_mines
        puts "\n You won!\n"
        exit
      end
    end
  end
end

def r
  myboard = Board.new()
  while(true)
    myboard.render
    print "\n > "
    input = gets
    myboard.check(input)
    print "\n"
  end
end

if CPAD
  puts "\n  Type 'r' to start playing."
else
  r
end
