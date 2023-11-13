# frozen_string_literal: true

require 'open-uri'

# app/controller/games_controller.rb
class GamesController < ApplicationController
  before_action :set_start_time, only: [:new]

  def new
    @letters = set_letters
    @start_time
  end

  def score
    @word = params[:word]
    letters = params[:letters].split(' ')
    time = calculate_time(params[:start_time])
    @result = { score: 0, message: 'Not in the grid', time: }

    @word.upcase.chars.each do |letter|
      return @result if !letters.include?(letter) || overused?(@word, letter, letters)
    end

    update_result(@word, @result, time)
  end

  private

  def set_letters
    letters = []
    10.times do
      letters << ('A'..'Z').to_a.sample
    end
    letters
  end

  def set_start_time
    @start_time = Time.now
  end

  def check_dictionnary(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    response = URI.open(url).read
    JSON.parse(response)
  end

  def overused?(attempt, letter, grid)
    word_count = attempt.upcase.chars.count { |c| c == letter }
    grid_count = grid.count { |c| c == letter }
    word_count > grid_count
  end

  def update_result(attempt, result, time)
    parsed = check_dictionnary(attempt)
    result[:score] = (5 * parsed['length']) - time if parsed['found']
    result[:message] = parsed['found'] ? 'Well done' : 'Not an english word'
  end

  def calculate_time(start_time)
    Time.now - Time.parse(start_time)
  end
end
