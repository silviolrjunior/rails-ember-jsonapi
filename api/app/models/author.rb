class Author < ActiveRecord::Base
  has_many :articles
  has_many :comments
  
  def jsonapi_type; "people"; end
end
