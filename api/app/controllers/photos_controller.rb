class PhotosController < ApplicationController
  def create
    run Photo::Create do |op|
      response.headers['Location'] = "http://example.com/photos/1"
      response.status = 201
      render json: op.to_hash
    end
  end
end