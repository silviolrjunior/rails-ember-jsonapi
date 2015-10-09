class PhotosController < ApplicationController
  def create
    run Photo::Create do |op|
      response.headers['Location'] = "http://example.com/photos/1"
      response.status = 201
      render json: op.to_hash
    end
  end
  
  def destroy
    run Photo::Delete do |op|
      response.status = :no_content
      render text: ""
    end
  end
end