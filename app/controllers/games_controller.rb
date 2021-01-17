require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = (0...10).map { (65 + rand(26)).chr }
    if !Rails.cache.exist?('total_score')
      Rails.cache.write('total_score', 0)
    end
  end

  def score_refresh
    redirect_to 'ask'
  end

  def score
    word = params[:word]
    letters = params[:letters].split
    result = JSON.parse(open("https://wagon-dictionary.herokuapp.com/#{word}").read)
    @total_score = Rails.cache.fetch('total_score').to_i

    if !result["found"]
      @message = "Sorry but #{word} is not a valid word"
    elsif !grid_inclusion?(word, letters)
      @message = "Sorry but #{word} cannot be formed of #{letters.join(",")}"
    else
      @message = "Congratulations! #{word} is a valid english word"
      @total_score = @total_score + word.length
      Rails.cache.write('total_score', @total_score.to_s)
    end
  end

  private
  def grid_inclusion?(attempt, grid)
    grid_count = form_hash(grid)
    attempt_count = form_hash(attempt.upcase.split(''))
    attempt_count.keys.all? do |letter|
      grid_count.include?(letter) && grid_count[letter] >= attempt_count[letter]
    end
  end

  def form_hash(string_array)
    hash = Hash.new(0)
    string_array.each { |letter| hash[letter] += 1 }
    hash
  end
end
