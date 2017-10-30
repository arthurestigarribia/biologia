function validaEmail() {
    var email = document.getElementById('email').value;

    if (email != 'admin') {
        if (!email.includes('@')) {
            return false;
        }
        
        var provedor = '';

        for (var i = 0; i < email.length; i++) {
            if (email[i] == '@') {
                provedor = email.substring(i++, email.length);
                break;
            }
        }

        if (!provedor.includes('.')) {
            return false;
        } else {
            return true;
        }
    } else {
        return true;
    }
}

function validaSenha() {
    var senha = document.getElementById('senha').value;

    if (senha == '') {
        return false;
    } else {
        return true;
    }
}

document.getElementById('form').onsubmit = function(){
	if (validaEmail() && validaSenha()) {
        document.getElementById('form').submit();
    } else {
    //    alert('Email inválido');
        document.getElementById('erro').innerHTML = 'Email inválido.';
    }
};