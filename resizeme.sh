#!/usr/bin/env bash
#======================HEADER============================================|
#AUTOR
# Jefferson Rocha <root@slackjeff.com.br>
#
#PROGRAMA
# Redimensiona e cria estrutura de fotos para post em blog de fotografias
#
#========================================================================|

#===========================VARIAVEIS
# Diretórios para enviar imagens prontas
thumbs="thumb"      # Capa das imagens
original="original" # Fotos em tamanho real

# Servidor para envio, utilizando o rsync para sincronia
server="slackjeff@slackjeff.com.br:public_html/fotos/debconf19"

#===========================INICIO
read -ep "Directory for enter: " directory
if [[ ! -d "$directory" ]]; then
    echo "Directory dont exist."
    exit 1
fi
pushd "$directory" &>/dev/null
# Criando diretórios necessários se precisar.
for dir in "$thumbs" "$original"; do
	if [[ ! -d "$dir" ]]; then
		mkdir "$dir"
	fi
done

# Gerando cabeçalho
cat <<EOF > index.html
<!DOCTYPE HTML>
    <!--
         CREATED BY resizeme.sh
     -->
 <html>
 	<head>
    	<title>Debconf19</title>
        <style>
              body {background-color: black;font-size: 1.2em; color: #00ff00;margin: 1em auto;max-width: 46em;}
              h1{text-align: center;}
              hr{margin-bottom: 4%;}
              p{color: white;}
              a:hover{background: #00ff00;}
        </style>
    </head>
    <body>
	<header>
            <h1>Debconf19</h1>
            <h2>Curitiba-PR-Brasil</h2>
        </header>
    <hr>
EOF

# Convertendo imagens para thumb
for x in *; do
    if [[ "$x" =~ .*\.(jpg|jpeg|png) ]]; then
        name="${x/%.*/}"
        extension="${x/#*./}"
        if convert "$x" -resize 120x90 "${name}-thumb.${extension}"; then
            echo "<a href="original/${name}.${extension}"><img src="thumb/${name}-thumb.${extension}"></a>" \
            >> 'index.html'
        fi
    fi
done

# Rodapé
cat <<EOF >> index.html
</body>
</html>
EOF


# Movendo thumbs e fotos originais
echo "Move ALL THUMBS for '$thumbs'"
if [[ -d "$thumbs" ]]; then
	mv *-thumb* "$thumbs" && echo "Moved Thumbs OK" &>/dev/null
fi

# Movendo arquivos originais
echo "Move ALL Original photos for '$original'"
mv *.{jpg,jpeg,png,mp4} "$original" &>/dev/null

# Retornando para o diretorio principal.
popd &>/dev/null

# Enviando para o servidor
rsync -avzh ${directory} "$server"
