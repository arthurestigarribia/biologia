require 'rubygems'
require 'data_mapper'
require 'dm-mysql-adapter'
require 'dm-migrations'
require 'sinatra'
require 'open-uri'
require './model.rb'
require 'digest/md5'

enable :sessions

set :session_secret, 'palavra_secreta_biologia'

def naoVazio(email, senha)
	return (email != '' || email != 'admin'  || senha != '')
end

def naoVazioNome(nome, email, senha)
	return (nome != '' || nome != 'admin' || email != '' || email != 'admin'  || senha != '')
end

def existe(email, senha)
	return Usuario.count(:email => email, :senha => senha) > 0
end

if !existe('admin', 'admin')
	admin = Usuario.new
	admin.nome = 'admin'
	admin.email = 'admin'
	admin.senha = Digest::MD5.hexdigest('admin')

	admin.save
else
	puts 'Admin já foi criado'
end

puts !existe('admin', 'admin')

def getUser(email, senha)
	return Usuario.first(:email => email, :senha => senha)
end

def getUserById(id)
	return Usuario.first(:id => id)
end

before '/biologia/calculadora' do
	if !session[:logado]
		redirect '/biologia/login'
	end
end

before '/biologia/historico/*' do
	if !session[:logado]
		redirect '/biologia/login'
	end
end

before '/biologia/calculadora/*' do
	if !session[:logado]
		redirect '/biologia/login'
	end
end

before '/biologia/admin/*' do
	if !session[:logado] && params['email'].to_s == 'admin' && params['senha'].to_s == 'admin'
		redirect '/biologia/login'
	end
end

get '/biologia/login' do
	erb :login
end

post '/biologia/login' do
	email = params['email'].to_s
	senha = Digest::MD5.hexdigest(params['senha'])

	if email == 'admin' && senha == Digest::MD5.hexdigest('admin')
		session[:logado] = true
		session[:id] = getUser(email, senha).id
		session[:nome] = 'admin'

		redirect session[:previous_url] || '/biologia/admin/usuarios'
	elsif existe(email, senha) && naoVazio(email, senha)
		session[:logado] = true
		session[:id] = getUser(email, senha).id
		session[:nome] = getUser(email, senha).nome

		redirect session[:previous_url] || '/biologia/calculadora'
	else
		@error = 'Login inválido ou inexistente.'
		
		erb :login
	end
end

get '/biologia/cadastro' do
	erb :cadastro
end

post '/biologia/cadastro' do
	nome = params['nome'].to_s
	email = params['email'].to_s
	senha = Digest::MD5.hexdigest(params['senha'])

	if !existe(email, senha) && naoVazioNome(nome, email, senha)
		usuario = Usuario.new
		usuario.nome = nome
		usuario.email = email
		usuario.senha = senha

		usuario.save

		session[:logado] = true
		session[:id] = getUser(email, senha).id
		session[:nome] = getUser(email, senha).nome

		redirect '/biologia/calculadora'
	else
		@error = 'Cadastro inválido ou já existente.'
		
		erb :cadastro
	end
end

get '/biologia/atualiza_cadastro/:id' do
	@usuario = getUserById(session[:id])

	erb :atualiza_cadastro
end

post '/biologia/atualiza_cadastro/:id' do
	id = params['id'].to_i

	nome = params['nome'].to_s
	email = params['email'].to_s
	senha = Digest::MD5.hexdigest(params['senha'])

	if !existe(email, senha) then
		usuario = Usuario.get(:id => id)
		
		usuario.update(:nome => nome, :email => email, :senha => senha)

		session[:logado] = true
		session[:id] = getUser(email, senha).id
		session[:nome] = getUser(email, senha).nome

		redirect '/biologia/calculadora'
	else
		@error = 'Cadastro inválido ou já existente.'
		
		erb :atualiza_cadastro
	end
end

get '/biologia/usuario/:id' do
	@usuario = getUserById(session[:id].to_i)

	erb :usuario
end

get '/biologia/logout' do
	session[:id] = nil
	session[:logado] = false
	session[:nome] = nil

	redirect '/biologia/login'
end

get '/biologia/remove_cadastro/:id' do
	id = params['id'].to_i

	session[:id] = nil
	session[:logado] = false
	session[:nome] = nil

	adapter = DataMapper.repository(:default).adapter
	adapter.execute("DELETE FROM biologia.cadeia WHERE usuario = " + id.to_s)

	adapter.execute("DELETE FROM biologia.usuarios WHERE id = " + id.to_s)

	redirect '/biologia/login'
end

get '/biologia/calculadora' do
	erb :index
end

get '/biologia/calculadora/:cadeia' do
	@cadeia = params['cadeia'].to_s

	erb :index
end

get '/biologia/calculadora/complementar/:cadeia' do
	cadeia = Cadeia.new

	cadeia.cadeia = params['cadeia'].to_s
	cadeia.usuario = session[:id]

	resp = ''

	if cadeia.representaAcidoNucleico
		acido = AcidoNucleico.new

		acido.cadeia = cadeia.cadeia
		acido.usuario = session[:id]

		if acido.isDNA then
			dna = DNA.new
			dna.cadeia = acido.cadeia
			dna.usuario = session[:id]
			
			resp = dna.complementar

			dna.save
		elsif acido.isRNA then
			rna = RNA.new
			rna.cadeia = acido.cadeia
			rna.usuario = session[:id]
			
			resp = rna.complementar

			rna.save
		else
			resp = 'Cadeia inválida.'
		end

		acido.save
	else 
		resp = 'Cadeia inválida.'
	end

	cadeia.save

	return resp.to_s
end

get '/biologia/calculadora/equivalente/:cadeia' do
	cadeia = Cadeia.new

	cadeia.cadeia = params['cadeia'].to_s
	cadeia.usuario = session[:id]

	resp = ''

	if cadeia.representaAcidoNucleico
		acido = AcidoNucleico.new

		acido.cadeia = cadeia.cadeia
		acido.usuario = session[:id]

		if acido.isDNA then
			dna = DNA.new
			dna.cadeia = acido.cadeia
			dna.usuario = session[:id]

			resp = dna.equivalente

		#	dna.save
		elsif acido.isRNA then
			rna = RNA.new
			rna.cadeia = acido.cadeia
			rna.usuario = session[:id]
		
			resp = rna.equivalente

		#	rna.save
		else
			resp = 'Cadeia inválida.'
		end

	#	acido.save
	else 
		resp = 'Cadeia inválida.'
	end

#	cadeia.save

	return resp.to_s
end

get '/biologia/calculadora/acidos/:cadeia' do
	cadeia = Cadeia.new

	cadeia.cadeia = params['cadeia'].to_s
	cadeia.usuario = session[:id]

	resp = ''

	if cadeia.representaAcidoNucleico
		acido = AcidoNucleico.new

		acido.cadeia = cadeia.cadeia
		acido.usuario = session[:id]

		if acido.isRNA then
			rna = RNA.new
			rna.cadeia = acido.cadeia
			rna.usuario = session[:id]
			
			resp = rna.acidos

#			rna.save
		elsif acido.isDNA then
			dna = DNA.new
			dna.cadeia = acido.cadeia
			dna.usuario = session[:id]

			resp = dna.acidos

#			dna.save
		else
			resp = 'Cadeia inválida.'
		end

#		acido.save
	else 
		resp = 'Cadeia inválida.'
	end

#	cadeia.save

	return resp.to_s
end

get '/biologia/historico/:id' do
	id = params['id'].to_i

	@itens = Cadeia.all(:usuario => id, :order => [:id.desc]).to_a

	erb :historico
end

get '/biologia/historico/limpa/:id' do
	id = params['id'].to_i

	adapter = DataMapper.repository(:default).adapter
	adapter.execute("DELETE FROM biologia.cadeia WHERE usuario = " + id.to_s)
	
	redirect '/biologia/historico/' + id.to_s
end

get '/biologia/ajuda' do
	erb :ajuda
end

get '/biologia/admin/usuarios' do
	id = params['id'].to_i

	@itens = Usuario.all.to_a

	erb :usuarios
end

get '/biologia/admin/remove_cadastro/:id' do
	id = params['id'].to_i

	user = Usuario.first(:id => id.to_i)

	if user.email =='admin' && user.senha == Digest::MD5.hexdigest('admin') then
		@erro = "Não é possível excluir nem editar o admin."
		redirect '/biologia/admin/usuarios'
	else
		adapter = DataMapper.repository(:default).adapter
		adapter.execute("DELETE FROM biologia.cadeia WHERE usuario = " + id.to_s)

		adapter.execute("DELETE FROM biologia.usuarios WHERE id = " + id.to_s)

		redirect '/biologia/admin/usuarios'
	end
end

get '/biologia/admin/atualiza_cadastro/:id' do
	id = params['id'].to_s

	user = Usuario.first(:id => id.to_i)

	if user.email =='admin' && user.senha == Digest::MD5.hexdigest('admin') then
		@erro = "Não é possível excluir nem editar o admin."
		redirect '/biologia/admin/usuarios'
	else
		@usuario = getUserById(id.to_i)

		erb :admin_atualiza_cadastro
	end
end

post '/biologia/admin/atualiza_cadastro/:id' do
	id = params['id'].to_s

	nome = params['nome'].to_s
	email = params['email'].to_s
	senha = Digest::MD5.hexdigest(params['senha']).to_s

	user = Usuario.first(:id => id.to_i)

	if user.email =='admin' && user.senha == Digest::MD5.hexdigest('admin') then
		@erro = "Não é possível excluir nem editar o admin."
		redirect '/biologia/admin/usuarios'
	else
		if !existe(email, senha)
			usuario = Usuario.first(:id => id)

			puts "Nome: " + nome.to_s + " " + email.to_s + " " + senha.to_s
		
			usuario.update(:nome => nome, :email => email, :senha => senha)

			redirect '/biologia/admin/usuarios'
		else
			@error = 'Cadastro inválido ou já existente.'
			
			redirect '/biologia/admin/usuarios'
		end
	end
end

get '/biologia/admin/cadastro' do
	erb :admin_cadastro
end

post '/biologia/admin/cadastro' do
	nome = params['nome'].to_s
	email = params['email'].to_s
	senha = Digest::MD5.hexdigest(params['senha'])

	if !existe(email, senha)
		usuario = Usuario.new
		usuario.nome = nome
		usuario.email = email
		usuario.senha = senha

		usuario.save

		redirect '/biologia/admin/usuarios'
	else 
		@erro = "Cadastro inválido ou já existente"

		erb :admin_cadastro
	end
end

get '/biologia/admin/historico/:id' do
	id = params['id'].to_i

	@itens = Cadeia.all(:usuario => id, :order => [:id.desc]).to_a

	erb :historico
end

get '/biologia/admin/historico/limpa/:id' do
	id = params['id'].to_i

	adapter = DataMapper.repository(:default).adapter
	adapter.execute("DELETE FROM biologia.cadeia WHERE usuario = " + id.to_s)
	
	redirect '/biologia/historico/' + id.to_s
end
