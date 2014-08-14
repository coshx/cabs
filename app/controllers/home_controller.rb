class HomeController < ApplicationController
  def index
  end
  def title
    @title = TITLES.detect {|t| t["slug"] == params[:title_slug]}
    if @title.present?
      render :index
    else
      redirect_to root_url
    end
  end
end
