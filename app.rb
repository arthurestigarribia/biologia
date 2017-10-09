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

def existe(email, senha)
	Usuario.all.each do |usuario|
		if usuario.email.to_s == email.to_s && usuario.senha.to_s == senha.to_s
			return true
		end
	end

	return false
end

def getUser(email, senha)
	Usuario.all.each do |usuario|
		if usuario.email.to_s == email.to_s && usuario.senha.to_s == senha.to_s
			return usuario
		end
	end

	return nil
end

def getUserById(id)
	Usuario.all.each do |usuario|
		if usuario.id == id
			return usuario
		end
	end

	return nil
end

puts getUserById(1).to_s

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

get '/biologia/login' do
	erb :login
end

post '/biologia/login' do
	email = params['email'].to_s
	senha = Digest::MD5.hexdigest(params['senha'])

	if existe(email, senha)
		session[:logado] = true
		session[:id] = getUser(email, senha).id
		session[:nome] = getUser(email, senha).nome

		redirect session[:previous_url] || '/biologia/calculadora'
	else
		@error = 'Login inválido ou inexistente.'
		redirect '/biologia/login'
	end
end

get '/biologia/cadastro' do
	erb :cadastro
end

post '/biologia/cadastro' do
	nome = params['nome'].to_s
	email = params['email'].to_s
	senha = Digest::MD5.hexdigest(params['senha'])

	if !existe(email, senha)
		usuario = Usuario.new
		usuario.nome = nome
		usuario.email = email
		usuario.senha = senha

		usuario.save

		session[:logado] = true
		session[:id] = getUser(email, senha).id
		session[:nome] = getUser(email, senha).nome

		redirect session[:previous_url] || '/biologia/calculadora'
	else
		@error = 'Cadastro inválido ou já existente.'
		redirect '/biologia/cadastro'
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

	if !existe(email, senha)
		usuario = Usuario.new
		usuario.nome = nome
		usuario.email = email
		usuario.senha = senha

		usuario.update(:id => id)

		session[:logado] = true
		session[:id] = getUser(email, senha).id
		session[:nome] = getUser(email, senha).nome

		redirect session[:previous_url] || '/biologia/calculadora'
	else
		@error = 'Cadastro inválido ou já existente.'
		redirect '/biologia/atualiza_cadastro' + id.to_s
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