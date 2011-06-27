#!/usr/bin/ruby

require 'rubygems'
require 'rspec'

require './life'

describe Rules, "#still_alive?" do
  it "should be false if underpopulated" do
    Rules.still_alive?(0).should == false
    Rules.still_alive?(1).should == false
  end

  it "should be false if overcrowded" do
    Rules.still_alive?(4).should == false
    Rules.still_alive?(5).should == false
    Rules.still_alive?(6).should == false
    Rules.still_alive?(7).should == false
    Rules.still_alive?(8).should == false
  end

  it "should be true if not underpopulated or overcrowded" do
    Rules.still_alive?(2).should == true
    Rules.still_alive?(3).should == true
  end
end

describe Rules, "#becomes_alive?" do
  it "should be false if not enough neighbours alive" do
    Rules.becomes_alive?(0).should == false
    Rules.becomes_alive?(1).should == false
    Rules.becomes_alive?(2).should == false
  end

  it "should be false if overcrowded" do
    Rules.becomes_alive?(4).should == false
    Rules.becomes_alive?(5).should == false
    Rules.becomes_alive?(6).should == false
    Rules.becomes_alive?(7).should == false
    Rules.becomes_alive?(8).should == false
  end

  it "should be true if exactly enough neighbours alive" do
    Rules.becomes_alive?(3).should == true
  end
end

describe Board do
  before(:each) do
    @board = Board.new
  end

  describe '#neighbour_coords' do
    it "should return coordinates surrounding (0,0)" do
      @board.neighbour_coords(0, 0).should == [
        [-1, -1], [0, -1], [1, -1],
        [-1,  0],          [1,  0],
        [-1,  1], [0,  1], [1,  1]
      ]
    end

    it "should return coordinates surrounding (5,2)" do
      @board.neighbour_coords(5, 2).should == [
        [4, 1], [5, 1], [6, 1],
        [4, 2],         [6, 2],
        [4, 3], [5, 3], [6, 3]
      ]
    end
  end

  describe '#next_board' do
    it "should be empty" do
      @board.next_board.living.should be_empty
    end
  end
end

describe Board, "with living at (5,5)" do
  before(:each) do
    @board = Board.new [[5,5]]
  end

  describe "#living_count_around" do
    it "should return 1 for (4,5) and (6,5)" do
      @board.living_count_around(4,5).should == 1
      @board.living_count_around(6,5).should == 1
    end

    it "should return 0 for (0,0) and (5,5)" do
      @board.living_count_around(0,0).should == 0
      @board.living_count_around(5,5).should == 0
    end
  end

  describe "#dead_neighbours" do
    it "should return cells around (5,5)" do
      @board.dead_neighbours.should == Set.new([
        [4,4], [5,4], [6,4],
        [4,5],        [6,5],
        [4,6], [5,6], [6,6]
      ])
    end
  end
end

describe Board, "with living at (3,3), (4,3), (5,3)" do
  before(:each) do
    @board = Board.new [[3,3], [4,3], [5,3]]
  end

  describe "#living_count_around" do
    it "should return 1 for (2,2) and (6,4)" do
      @board.living_count_around(2,2).should == 1
      @board.living_count_around(6,4).should == 1
    end

    it "should return 1 for (3,3) and (5,3)" do
      @board.living_count_around(3,3).should == 1
      @board.living_count_around(5,3).should == 1
    end

    it "should return 2 for (4,3)" do
      @board.living_count_around(4,3).should == 2
    end

    it "should return 0 for (1,1) and (2,7)" do
      @board.living_count_around(1,1).should == 0
      @board.living_count_around(2,7).should == 0
    end
  end

  describe "#dead_neighbours" do
    it "should return cells around living cells" do
      @board.dead_neighbours.should == Set.new([
        [2,2], [3,2], [4,2], [5,2], [6,2],
        [2,3],                      [6,3],
        [2,4], [3,4], [4,4], [5,4], [6,4],
      ])
    end
  end

  describe "#next_board" do
    it "should become a vertical blinker" do
      @board.next_board.living.should == Set.new([
        [4,2],
        [4,3],
        [4,4]
      ])
    end
  end
end
