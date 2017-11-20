require 'rubygems'
require 'tk'
require 'tkextlib/bwidget'
require 'data_mapper'
require 'dm-mysql-adapter'
require 'dm-migrations'
require 'open-uri'
require './model.rb'
require 'digest/md5'

class App
	attr_accessor :usuario
	attr_accessor :root

	def getUser(email, senha)
		return Usuario.first(:email => email, :senha => senha)
	end

	def getUserById(id)
		return Usuario.first(:id => id)
	end

	def existe(email, senha)
		return Usuario.count(:email => email, :senha => senha) > 0
	end

	def initialize(usuario, root)
		@usuario = usuario
		@root = root

		root.title 'Calculadora de Ácidos Nucleicos'
		
		self.carregaApp
	end

	def carregaApp
		for e in @root.winfo_children()
			e.destroy()
		end

		var1 = TkVariable.new
		var1.value = @usuario.id

		label1 = TkLabel.new(@root) {
			text 'Cadeia:'
			pack('fill' => 'x')
		}

		entry1 = TkEntry.new(@root) {
			pack('fill' => 'x')
		}

		button1 = TkButton.new(@root) {
			text 'Calcular'

			command {
				cadeia = AcidoNucleico.new

				if entry1.get != nil && entry1.get.to_s != ""
					cadeia.cadeia = entry1.get.to_s
					cadeia.usuario = var1.value.to_i

					if cadeia.isRNA
						c = DNA.new
						c.cadeia = cadeia.cadeia
						c.usuario = cadeia.usuario

						messageBox = Tk.messageBox(
							'type' => 'ok',
							'icon' => 'info',
							'title' => 'Resultado',
							'message' => "Complementar: " + cadeia.complementar.to_s + "; Equivalente: " + cadeia.equivalente.to_s + "; Ácidos: " + cadeia.acidos.to_s
						)

						c.save
						cadeia.save
					elsif cadeia.isDNA
						c = RNA.new
						c.cadeia = cadeia.cadeia
						c.usuario = cadeia.usuario

						messageBox = Tk.messageBox(
							'type' => 'ok',
							'icon' => 'info',
							'title' => 'Resultado',
							'message' => "Complementar: " + cadeia.complementar.to_s + "; Equivalente: " + cadeia.equivalente.to_s
						)

						c.save
						cadeia.save
					else
						messageBox = Tk.messageBox(
							'type' => 'ok',
							'icon' => 'info',
							'title' => 'Resultado',
							'message' => "Cadeia inválida."
						)
					end
				else
					messageBox = Tk.messageBox(
						'type' => 'ok',
						'icon' => 'info',
						'title' => 'Resultado',
						'message' => "Cadeia vazia."
					)
				end
			}

			pack('fill' => 'x')
		}
	end
end

class Login
	def getUser(email, senha)
		return Usuario.first(:email => email, :senha => senha)
	end

	def form
		root = TkRoot.new {
			title "Login e Cadastro"
			height 800
			width 600
		}

		label1 = TkLabel.new(root) {
			text 'Email:'
			pack('fill' => 'x')
		}

		entry1 = TkEntry.new(root) {
			pack('fill' => 'x')
		}

		label2 = TkLabel.new(root) {
			text 'Senha:'
			pack('fill' => 'x')
		}

		entry2 = TkEntry.new(root) {
			pack('fill' => 'x')
		}

		button1 = TkButton.new(root) {
			text 'Entrar'
			command {
				email = entry1.get.to_s
				senha = Digest::MD5.hexdigest(entry2.get.to_s).to_s

				if email == nil || senha == nil
					messageBox = Tk.messageBox(
						'type' => 'ok',
						'icon' => 'error',
						'title' => 'Login',
						'message' => "Login inválido"
					)
				else 
					user = Usuario.first(:email => email, :senha => senha)
	
					if user != nil
						app = App.new(user, root)
					else
						messageBox = Tk.messageBox(
							'type' => 'ok',
							'icon' => 'error',
							'title' => 'Login inválido',
							'message' => "Login inválido"
						)	
					end
				end
			}
			pack('fill' => 'x')
		}

		label3 = TkLabel.new(root) {
			text 'Nome:'
			pack('fill' => 'x')
		}

		entry3 = TkEntry.new(root) {
			pack('fill' => 'x')
		}

		label4 = TkLabel.new(root) {
			text 'Email:'
			pack('fill' => 'x')
		}

		entry4 = TkEntry.new(root) {
			pack('fill' => 'x')
		}

		label5 = TkLabel.new(root) {
			text 'Senha:'
			pack('fill' => 'x')
		}

		entry5 = TkEntry.new(root) {
			pack('fill' => 'x')
		}

		button2 = TkButton.new(root) {
			text 'Cadastrar'
			command {
				nome = entry3.get.to_s
				email = entry4.get.to_s
				senha = entry5.get.to_s

				if email == nil || senha == nil
					messageBox = Tk.messageBox(
						'type' => 'ok',
						'icon' => 'error',
						'title' => 'Cadastro inválido',
						'message' => "Cadastro inválido"
					)
				else 
					user = Usuario.new
					user.nome = nome
					user.email = email
					user.senha = Digest::MD5.hexdigest(senha)
	
					u = Usuario.first(:email => email, :senha => senha)

					if u == nil && email.to_s != 'admin' && senha.to_s != 'admin'
						user.save

						app = App.new(user, root)
					else
						messageBox = Tk.messageBox(
							'type' => 'ok',
							'icon' => 'error',
							'title' => 'Cadastro inválido',
							'message' => "Cadastro inválido"
						)
					end
				end
			}

			pack('fill' => 'x')
		}

		Tk.mainloop
	end

	def initialize
		form
	end
end

app = Login.new