require "mongoid"
Mongoid.load!("mongoid.yml", :production)

class Movie
  include Mongoid::Document
  field :name, type: String
  field :directors, type: Array
  field :editors, type: Array
  field :actors, type: Array
  field :types, type: Array
  field :countries, type: Array
  field :language, type: Array
  field :date, type: String
  field :length, type: String
  field :tags, type: Array
  field :rate, type: String
  field :people, type: String
  field :year, type:String
  field :movie_id, type: String
  field :summary, type: String
  field :cover_id, type: String
  field :directors_pids, type: Array
  field :casts_pids, type: Array
end

class Top
  include Mongoid::Document
  field :name, type: String
  field :directors, type: Array
  field :editors, type: Array
  field :actors, type: Array
  field :types, type: Array
  field :countries, type: Array
  field :language, type: Array
  field :date, type: String
  field :length, type: String
  field :tags, type: Array
  field :rate, type: String
  field :people, type: String
  field :year, type:String
  field :movie_id, type: String
  field :summary, type: String
end
