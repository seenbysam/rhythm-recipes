class MatchesController < ApplicationController
  def index
    def index
      if params[:reset] == "true"
        session.delete(:match_data)
        redirect_to matches_path
      end
      @match_data = session[:match_data] || {}
    end
  end

  def create
    session[:match_data][:selected_recipe_id] = params[:recipe_id]

    @music = MusicSuggestion.find(session[:match_data]["selected_music_id"])
    @recipe = Recipe.find(params[:recipe_id]) # or session[:match_data]["selected_recipe_id"]

    @match = Match.new(
      user: current_user,
      music_suggestion: @music,
      recipe: @recipe,
      recipe_name: @recipe.name,
      recipe_description: @recipe.description
    )

    if @match.save
      redirect_to match_path(@match)
    else
      redirect_to recipe_suggestions_matches_path, alert: "Could not create match."
    end
  end

  def show
    @match = Match.find(params[:id])
  end

  def save
    @match = Match.find(params[:id])
    @match.update(saved: true)

  respond_to do |format|
    format.turbo_stream
    format.html { redirect_to match_path(@match) }
  end
  end

  def unsave
    @match = Match.find(params[:id])
    @match.update(saved: false)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to match_path(@match) }
    end
  end

  def generate
    session[:match_data] = {
      food_type: params[:food_type_selection],
      difficulty: params[:difficulty_selection],
      genres: params[:music_genres],
      format: params[:music_format_selection]
    }
    redirect_to music_suggestions_matches_path
  end

  def match_results
    @selected_food = session[:match_data]["food_type"]
    @difficulty = session[:match_data]["difficulty"]
  end

  def music_suggestions
    if session[:match_data] == nil
      redirect_to matches_path
    else
      @genres = session[:match_data]["genres"]
      @format = session[:match_data]["format"]

      if @format == "Album"
        @albums_by_genre = MusicSuggestion.where(genre: @genres, album: true).sample(3)
        @music_suggestions = @albums_by_genre.sample(3)
      elsif @format == "Playlist"
        @playlists_by_genre = MusicSuggestion.where(genre: @genres, album: false)
        @music_suggestions = @playlists_by_genre.sample(3)
      end
    end
  end

  def select_music
    session[:match_data] ||= {}
    session[:match_data][:selected_music_id] = params[:music_suggestion_id]
    redirect_to recipe_suggestions_matches_path
  end

  def recipe_suggestions
    if session[:match_data] == nil
      redirect_to matches_path
    else
    @selected_food = session[:match_data]["food_type"]
    @difficulty = session[:match_data]["difficulty"]
    @recipes = Recipe.where(
      "LOWER(food_type) = ? AND LOWER(difficulty) = ?",
      @selected_food.downcase,
      @difficulty.downcase
    ).sample(4)
    session[:match_data]["selected_recipe_id"] = params[:recipe_id]
    end
  end
end
