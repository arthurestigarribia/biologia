require './model.rb'

id = 1

cad = Cadeia.all(:usuario => id)
cad.destroy