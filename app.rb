require 'rubygems'
require 'sinatra'
require 'sqlite3'
#require 'sinatra/reloader'

# configure do
#   enable :sessions
# end
def get_db
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true

  db
end

get '/showusers' do

  @arr = []
  get_db.execute 'select * from Users order by id desc' do |row|
    @arr.push({
                  :id => row['id'],
                  :username => row['username'],
                  :phone => row['phone'],
                  :datestemp => row['datestemp'],
                  :barber => row['barber'],
                  :color => row['color']
              })

    #print row['username']
    #print "\t-\t"
    #puts row['datestemp']
    #puts "#{row[1]} записался на #{row[3]}"
    #puts "============"
  end

  @foo = [
      {:bar => 1},
      {:bar => 98},
      {:bar => 90}
  ]

  erb :showusers
end

configure do
  db = get_db

  db.execute 'create table IF NOT EXISTS barbers
  (
  id   integer
  constraint barbers_pk
  primary key autoincrement,
              name text
  );'

  db.execute 'INSERT or ignore INTO barbers (id, name) VALUES
  (3, \'Gus Fring\'),
  (1, \'Jessie Pinkman\'),
  (2, \'Walter White\')'

  db.execute 'CREATE TABLE IF NOT EXISTS
  "Users" 
  (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT, 
    "username" TEXT, 
    "phone" TEXT, 
    "datestemp" TEXT, 
    "barber" TEXT, 
    "color" TEXT
  )'
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

  @barbers = []
  get_db.execute 'select * from barbers' do |row|
    @barbers.push({
                      :id =>row['id'],
                      :name => row['name']
    })
  end

  #@barbers = [
  #    { :id => 1, :name => 'Asd'},
  #    { :id => 2, :name => 'QWe'},
  #    {...}
  #]
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
  db = get_db
  db.execute 'insert into
Users 
(
  username,
  phone,
  datestemp,
  barber,
  color
)
values (?, ?, ?, ?, ?)', [@username, @phone, @datetime, @barber, @color]


  erb "OK, username is #{@username} date is ,#{@datetime} , 
  phone is #{@phone} , your barber #{@barber} , your color: #{@color}"
end

