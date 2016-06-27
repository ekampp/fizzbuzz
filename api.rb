require_relative 'environment'

module FizzBuzz
  class API < Grape::API
    class Number
      include ActiveModel::Model
      attr_accessor :value, :favorite

      MAX = 100_000_000_000

      def display_value
        if fizz? && buzz?
          'fizz buzz'
        elsif fizz?
          'fizz'
        elsif buzz?
          'buzz'
        else
          value.to_s
        end
      end

      def as_json
        {
          id: value,
          value: display_value,
          favorite: favorite,
        }
      end

      private

        def fizz?
          (value % 3).zero?
        end

        def buzz?
          (value % 5).zero?
        end
    end

    class User < ActiveRecord::Base
      has_secure_password

      has_many :favorite_numbers
    end

    class FavoriteNumber < ActiveRecord::Base
      belongs_to :user
      validates :user, presence: true
      validates :number, presence: true
    end

    version 'v1', using: :path
    format :json

    helpers do
      def current_user
        @current_user || User.new
      end

      def retrieve_user_if_available
        # Because signing in is optional we deconstruct the Authorization header and authenticate the user only if it's
        # present.
        # If credentials are supplied that doens't match a user, create a matching user for them.
        if headers['Authorization'].present?
          email, password = Base64.decode64(headers['Authorization'].split(' ', 2).second).split(':')
          user = User.where(email: email).take
          user ||= User.create!(email: email, password: password, password_confirmation: password)
          @current_user = user.authenticate(password)
        end
      end
    end

    before do
      header "Access-Control-Allow-Origin", "*"
    end

    namespace :favorites do
      params do
        requires :favorite, type: Hash do
          requires :number, type: Integer
        end
      end
      post do
        retrieve_user_if_available
        current_user.favorite_numbers.create! number: params.favorite.number
        status 204
        ''
      end

      params do
        requires :id, type: Integer
      end
      route_param :id do
        get do
          retrieve_user_if_available
          fav = current_user.favorite_numbers.where(number: params.id).take!
          {
            favorite: {
              id: fav.number,
              number: fav.number,
            }
          }
        end

        delete do
          retrieve_user_if_available
          current_user.favorite_numbers.where(number: params.id).destroy_all
          status 204
          ''
        end
      end
    end

    namespace :numbers do
      params do
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 100
      end
      get do
        retrieve_user_if_available

        params.per_page = 100 if params.per_page > 100
        params.per_page = 1 if params.per_page <= 0
        params.page = 1 if params.page <= 0

        limit = params.per_page * params.page
        limit = Number::MAX if limit > Number::MAX

        offset = limit - params.per_page + 1
        offset = 0 if offset < 0

        range = (offset..limit)

        favorite_numbers = current_user.favorite_numbers.map(&:number)

        numbers = range.to_a.collect { |n| Number.new(value: n, favorite: favorite_numbers.include?(n)).as_json }

        {
          numbers: numbers,
        }
      end

      params do
        requires :id, type: Integer
      end
      route_param :id do
        get do
          number = Number.new(value: params.id)
          {
            number: number.as_json
          }
        end
      end
    end
  end
end
