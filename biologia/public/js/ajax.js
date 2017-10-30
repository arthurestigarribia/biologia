function tem(texto, letra) {
    for (var i = 0; i < texto.length; i++) {
        if (texto[i] == letra) {
            return true;
        }
    }

    return false;
}

function verificaRNA() {
    var cadeia = document.getElementById("cadeia").value;

    for (var i = 0; i < cadeia.length; i++) {
        if (cadeia[i] != 'A' && cadeia[i] != 'C' && cadeia[i] != 'G' && cadeia[i] != 'U') {
            return false;
        }
    }

    return true;
}

function verificaDNA() {
    var cadeia = document.getElementById("cadeia").value;

    for (var i = 0; i < cadeia.length; i++) {
        if (cadeia[i] != 'A' && cadeia[i] != 'C' && cadeia[i] != 'G' && cadeia[i] != 'T') {
            return false;
        }
    }

    return true;
}

function verifica() {
    var cadeia = document.getElementById("cadeia").value;

    for (var i = 0; i < cadeia.length; i++) {
        if (cadeia[i] != 'A' && cadeia[i] != 'C' && cadeia[i] != 'G' && cadeia[i] != 'T' && cadeia[i] != 'U') {
            return false;
        }
    }

    return !(tem(cadeia, 'T') && tem(cadeia, 'U'));
}

function criaObjetoAjax(){
    if (window.XMLHttpRequest) {
        xmlhttp = new XMLHttpRequest();                     // modern browsers
    } else {
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");   // old IE browsers
    }
    return xmlhttp;
}

function complementar() {
    var xhttp = criaObjetoAjax();

    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            document.getElementById("complementar").innerHTML = this.responseText;
        }
    };

    xhttp.open("GET", "/biologia/calculadora/complementar/" + document.getElementById('cadeia').value, true);
    xhttp.send(); 
}

function equivalente() {
    var xhttp = criaObjetoAjax();

    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            document.getElementById("equivalente").innerHTML = this.responseText;
        }
    };

    xhttp.open("GET", "/biologia/calculadora/equivalente/" + document.getElementById('cadeia').value, true);
    xhttp.send(); 
}

function acidos() {
    var xhttp = criaObjetoAjax();

    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            document.getElementById("acidos").innerHTML = this.responseText;
        }
    };

    xhttp.open("GET", "/biologia/calculadora/acidos/" + document.getElementById('cadeia').value, true);
    xhttp.send(); 
}

function executa(){
    if (verifica()) {
        complementar();
        equivalente();
        acidos();
    } else {
        alert('Cadeia inválida: ela só pode conter as letras maiúsculas A, C, G, T e U e as letras T e U não podem aparecer na mesma cadeia.');
    }
}

function executaRNA() {
    if (verificaRNA()) {
        acidos();
    } else {
        alert('Cadeia inválida: ela só pode conter as letras maiúsculas A, C, G e U.');
    }
}

function historico(){
    var xhttp = criaObjetoAjax();

    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            document.getElementById("historico").innerHTML = this.responseText;
        }
    };

    xhttp.open("GET", '/biologia/historico/dados', true);
    xhttp.send(); 
}