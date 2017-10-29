require 'rubygems'
require 'data_mapper'
require 'dm-mysql-adapter'
require 'dm-migrations'

DataMapper::Logger.new($stdout, :error)

DataMapper.setup(:default, 'mysql://root:lachie1234@localhost:3306/biologia')

class Usuario
	include DataMapper::Resource

	property :id, Serial
	property :nome, String
	property :email, String
	property :senha, String
end

class Cadeia
	include DataMapper::Resource

	property :id, Serial
	property :cadeia, String
	property :usuario, Integer

	def representaAcidoNucleico
		i = 0
		t = cadeia.size

		while i < t
			if cadeia[i] != 'A' && cadeia[i] != 'a' && cadeia[i] != 'C' && cadeia[i] != 'c' && cadeia[i] != 'G' && cadeia[i] != 'g' && cadeia[i] != 'T' && cadeia[i] != 't' && cadeia[i] != 'U' && cadeia[i] != 'u' then
				return false
			end

			i += 1
		end

		return true
	end
end

class AcidoNucleico < Cadeia
	include DataMapper::Resource

	property :id, Serial
	property :cadeia, String
	property :usuario, Integer

	def isDNA
		if cadeia.include?('U') || cadeia.include?('u') then
			return false
		end
		
		return true
	end

	def isRNA
		if cadeia.include?('T') || cadeia.include?('t') then
			return false
		end
		
		return true
	end

	def complementar
		if self.isDNA
			dna = DNA.new
			dna.cadeia = self.cadeia
			return dna.complementar
		elsif self.isRNA
			rna = RNA.new
			rna.cadeia = self.cadeia
			return rna.complementar
		else
			return 'Cadeia inválida.'
		end
	end

	def equivalente
		if self.isDNA
			dna = DNA.new
			dna.cadeia = self.cadeia
			return dna.equivalente
		elsif self.isRNA
			rna = RNA.new
			rna.cadeia = self.cadeia
			return rna.equivalente
		else
			return 'Cadeia inválida.'
		end
	end

	def acidos
		if self.isDNA
			dna = DNA.new
			dna.cadeia = self.cadeia
			return dna.acidos
		elsif self.isRNA
			rna = RNA.new
			rna.cadeia = self.cadeia
			return rna.acidos
		else
			return 'Cadeia inválida.'
		end
	end
end

class DNA < Cadeia
	include DataMapper::Resource

	property :id, Serial
	property :cadeia, String
	property :usuario, Integer

	def complementar
		str = ''
		i = 0

		while i < cadeia.size
			case cadeia[i]
				when 'A'
					str = str + 'T'
				when 'T'
					str = str + 'A'
				when 'C'
					str = str + 'G'
				when 'G'
					str = str + 'C'
				else
					str = str + ''
			end

			i = i + 1
		end

		str
	end

	def equivalente
		str = ''
		i = 0

		while i < cadeia.size
			case cadeia[i]
				when 'A'
					str = str + 'A'
				when 'T'
					str = str + 'U'
				when 'C'
					str = str + 'C'
				when 'G'
					str = str + 'G'
				else
					str = str + ''
			end

			i = i + 1
		end

		str
	end

	def acidos
		return 'É um DNA e não corresponde a nenhum aminoácido.'
	end
end

class RNA < Cadeia
	include DataMapper::Resource

	property :id, Serial
	property :cadeia, String
	property :usuario, Integer

	def complementar
		str = ''
		i = 0

		while i < cadeia.size
			case cadeia[i]
				when 'A'
					str = str + 'U'
				when 'U'
					str = str + 'A'
				when 'C'
					str = str + 'G'
				when 'G'
					str = str + 'C'
				else
					str = str + ''
			end

			i = i + 1
		end

		str
	end

	def equivalente
		str = ''
		i = 0

		while i < cadeia.size
			case cadeia[i]
				when 'A'
					str = str + 'A'
				when 'U'
					str = str + 'T'
				when 'C'
					str = str + 'C'
				when 'G'
					str = str + 'G'
				else
					str = str + ''
			end

			i = i + 1
		end

		str
	end

	def acidos
		x = []

		if cadeia.size % 3 == 0

		elsif cadeia.size % 3 == 1
			cadeia[cadeia.size] = ' '
		elsif cadeia.size % 3 == 2
			cadeia[cadeia.size] = ' '
			cadeia[cadeia.size] = ' '
		end

		i = 0
		j = 0

		while i < cadeia.size && j < cadeia.size
			if cadeia[i] == 'A'
				if cadeia[i + 1] == 'A' && cadeia[i + 2] == 'A'
					x[j] = 'Lisina'
				elsif cadeia[i + 1] == 'A' && cadeia[i + 2] == 'G'
					x[j] = 'Lisina'
				elsif cadeia[i + 1] == 'A' && cadeia[i + 2] == 'C'
					x[j] = 'Aspargina'
				elsif cadeia[i + 1] == 'A' && cadeia[i + 2] == 'U'
					x[j] = 'Aspargina'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'A'
					x[j] = 'Arginina'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'G'
					x[j] = 'Arginina'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'C'
					x[j] = 'Serina'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'U'
					x[j] = 'Serina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'A'
					x[j] = 'Treonina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'G'
					x[j] = 'Treonina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'C'
					x[j] = 'Treonina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'U'
					x[j] = 'Treonina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'A'
					x[j] = 'Isoleucina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'G'
					x[j] = 'Start'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'C'
					x[j] = 'Isoleucina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'U'
					x[j] = 'Isoleucina'
				else 
					x[j] = 'Desconhecido'
				end
			elsif cadeia[i] == 'G'
				if cadeia[i + 1] == 'A' && cadeia[i + 2] == 'A'
					x[j] = 'Ácido glutâmico'
				elsif cadeia[i + 1] == 'A' && cadeia[i + 2] == 'G'
					x[j] = 'Ácido gutâmico'
				elsif cadeia[i + 1] == 'A' && cadeia[i + 2] == 'C'
					x[j] = 'Ácido aspárgico'
				elsif cadeia[i + 1] == 'A' && cadeia[i + 2] == 'U'
					x[j] = 'Ácido aspárgico'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'A'
					x[j] = 'Glicina'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'G'
					x[j] = 'Glicina'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'C'
					x[j] = 'Glicina'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'U'
					x[j] = 'Glicina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'A'
					x[j] = 'Alanina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'G'
					x[j] = 'Alanina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'C'
					x[j] = 'Alanina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'U'
					x[j] = 'Alanina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'A'
					x[j] = 'Valina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'G'
					x[j] = 'Valina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'C'
					x[j] = 'Valina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'U'
					x[j] = 'Valina'
				else 
					x[j] = 'Desconhecido'
				end
			elsif cadeia[i] == 'C'
				if cadeia[i + 1] == 'A' && cadeia[i + 2] == 'A'
					x[j] = 'Glutamina'
				elsif cadeia[i + 1] == 'A' && cadeia[i + 2] == 'G'
					x[j] = 'Glutamina'
				elsif cadeia[i + 1] == 'A' && cadeia[i + 2] == 'C'
					x[j] = 'Histidina'
				elsif cadeia[i + 1] == 'A' && cadeia[i + 2] == 'U'
					x[j] = 'Histidina'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'A'
					x[j] = 'Arginina'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'G'
					x[j] = 'Arginina'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'C'
					x[j] = 'Arginina'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'U'
					x[j] = 'Arginina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'A'
					x[j] = 'Prolina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'G'
					x[j] = 'Prolina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'C'
					x[j] = 'Prolina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'U'
					x[j] = 'Prolina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'A'
					x[j] = 'Leucina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'G'
					x[j] = 'Leucina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'C'
					x[j] = 'Leucina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'U'
					x[j] = 'Leucina'
				else 
					x[j] = 'Desconhecido'
				end
			elsif cadeia[i] == 'U'
				if cadeia[i + 1] == 'A' && cadeia[i + 2] == 'A'
					x[j] = 'Stop'
				elsif cadeia[i + 1] == 'A' && cadeia[i + 2] == 'G'
					x[j] = 'Stop'
				elsif cadeia[i + 1] == 'A' && cadeia[i + 2] == 'C'
					x[j] = 'Tirosina'
				elsif cadeia[i + 1] == 'A' && cadeia[i + 2] == 'U'
					x[j] = 'Tirosina'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'A'
					x[j] = 'Stop'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'G'
					x[j] = 'Triptofano'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'C'
					x[j] = 'Cisteína'
				elsif cadeia[i + 1] == 'G' && cadeia[i + 2] == 'U'
					x[j] = 'Cisteína'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'A'
					x[j] = 'Serina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'G'
					x[j] = 'Serina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'C'
					x[j] = 'Serina'
				elsif cadeia[i + 1] == 'C' && cadeia[i + 2] == 'U'
					x[j] = 'Serina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'A'
					x[j] = 'Leucina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'G'
					x[j] = 'Leucina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'C'
					x[j] = 'Fenilalanina'
				elsif cadeia[i + 1] == 'U' && cadeia[i + 2] == 'U'
					x[j] = 'Fenilalanina'
				else
					x[j] = 'Desconhecido'
				end
			else
				break
			end
			
			i = i + 3
			j = j + 1
		end

		x.to_s
	end
end

DataMapper.finalize

DataMapper.auto_migrate!
DataMapper.auto_upgrade!