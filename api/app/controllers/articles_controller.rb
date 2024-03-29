class ArticlesController < ApplicationController
  def index
    op = Article::Index.(params)
    render json: op.to_hash
  end
  
  def show
    op = Article::Show.(params)
    render json: op.to_hash
  end
  
  def update
    run Article::Update do |op|
      response.status = 201
      render json: op.to_hash
    end
  end
  
  def relationship
    op = Article::Relationship.(params)
    render json: op.to_hash
  end
  
  def relationships
    op = Article::Relationships.(params)
    render json: op.to_hash
  end
  
  def relationships_create
    run Article::Relationships::Create do |op|
      response.status = :no_content
      render text: ""
    end
  end

  def relationships_update
    run Article::Relationships::Update do |op|
      response.status = :no_content
      render text: ""
    end
  end
  
  def relationships_destroy
    run Article::Relationships::Delete do |op|
      response.status = :no_content
      render text: ""
    end
  end
end