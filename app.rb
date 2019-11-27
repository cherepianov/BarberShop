require 'rubygems'
require 'sinatra'
#require 'sinatra/reloader'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

get '/about' do
  @error = "something wrong!"
  erb :about
end
get '/visit' do
  erb :visit
end

post '/visit' do
  @username = params[:username]
  @phone = params[:phone]
  @datetime = params[:datetime]
  @barber = params[:barber]
  @color = params[:color]

#для каждой пары ключ-значение
  hh = {:username => 'введите имя', 
        :phone => "введите телефон", 
        :datetime => "введите дату и время"}
        #если параметр пуст
        hh.each do |key, value|
          if params[key] == ""
          #переменной error присовить value из хэша hh
          #а value из хэша hh это сообщение об ошибке
          #т.е. переменной error присовить сообщение об ошибке
          @error = hh[key]
          #вернуть представление visit
          return erb :visit
        end
  end

  erb "OK, username is #{@username} date is ,#{@datetime} , 
  phone is #{@phone} , your barber #{@barber} , your color: #{@color}"
end