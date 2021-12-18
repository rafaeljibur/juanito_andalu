#!/bin/bash

#**********************************************************#
#*********************JUANITO_ANDALU***********************#
#**********************************************************#

# Colores que he usado para que se vea más bonito
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
yellowColour="\e[0;33m\033[1m"
greenColour="\e[0;32m\033[1m"
blueColour="\e[0;34m\033[1m"
whiteColour="\e[1;37m\033[1m"

# Autor: Rafa Er Loco


######## FUNCIONAMIENTO DEL PROGRAMA ############


# Recibe un fichero con texto plano, te elimina las palabras repetidas te borra las , y los . y te genera un diccionario para fuerza bruta
# Y te filtra por longitud de palabras

# $1 debe ser un fichero con texto plano



# Comprobamos si el UID es del usuario root

if [ $UID -ne 0 ];then
	echo -e "${redColour}Debes ejecutar el script como root${endColour}"
	exit 1
fi

# Comprobamos si el número de parámetros es correcto

if [ $# -ne 1 ]; then
	echo -e "${redColour}Debe colocar un sólo parámetro y debe ser un fichero${endColour}"
	exit 2
fi

# Comprobamos el primer parámetro existe

if [ ! -e $1 ]; then
	echo -e "${redColour}$1 no existe${endColour}"
	exit 3
fi


# Comprobamos si el parámetro es un fichero

if [ ! -f $1 ];then
	echo -e "${redColour}El parámetro no es un fichero${endColour}"
	exit 4
fi


# Comprobamos que tiene los paquetes necesarios para que funcione todo correctamente (para usar el comando unique hay que tener instalado el paquete john)

john &>/dev/null

if [ $? -ne 0 ];then
	echo -en "${redColour}Al parecer no tienes el paquete john instalado y es necesario (utilize sudo apt-get install john -y) o escriba la letra "y": ${endColour}"
	read y
fi


# Y si el usuario escribe la letra y se le instala el paquete john

if [[ $y == "y" ]];then
	clear
	sudo apt install john -y &>/dev/null && echo -e "${greenColour}Paquete john instalado correctamente${endColour}"
	echo "Espere mientra arranca el programa..."
	sleep 4
fi


# Bucle for para crear nuestro diccionario

for lineas in `cat $1`; do
	if [ ${#lineas} -ge 1 ];then
	echo $lineas >> diccionario_palabras.txt
	fi
done

# Eliminar las palabras repetidas

if [ -e diccionario_filtrado.txt ];then
	rm diccionario_filtrado.txt
fi

sort diccionario_palabras.txt | unique diccionario_filtrado.txt &>/dev/null

# Borramos todos los puntos y las comas que haya en el texto

cat diccionario_filtrado.txt | sed 's/,//g' | tr -d . > diccionario.txt

# Borramos el fichero diccionario_palabras.txt y diccionario_filtrado.txt

rm diccionario_palabras.txt && rm diccionario_filtrado.txt


# Parte de John The Ripper Ezpañó (By Guillermo)

clear
read -p "Escribe el nombre de tu víctima (tiene que ser un nombre de usuario): " victima

id $victima &>/dev/null

# Comprobamos si el usuario existe

if [ $? -ne 0 ]; then
	echo -e "${redColour}El usuario $victima no existe${endColour}"
	exit 5
fi

read -p "Está todo listo, ¿Quieres que empieze el ataque de fuerza bruta? si/no: " sino

# Abrimos un case y depende lo que escribamos salta a un caso u otro

case $sino in

	[Ss]i)
		clear
		echo "Empezando ataque..."
		sleep 2
		# Buscamos la línea del fichero shadow
		linea=`grep -w ^$victima /etc/shadow`

		# Buscamos el trozo de contrasela completo
		objetivo=`echo $linea | cut -d: -f2`
		# Sacamos el algoritmo y la sal de la línea
		alg=`echo $linea | cut -d: -f2 | cut -d\$ -f2`
		sal=`echo $linea | cut -d: -f2 | cut -d\$ -f3`

		# Empieza el bucle for
		encontrado=0
		for palabra in `cat diccionario.txt` ; do
			posible=`openssl passwd -$alg -salt $sal $palabra`
			if [[ $posible == $objetivo ]];then
			   echo "¡¡Contraseña encontrada!! :D "
			   echo -e "La contraseña del usuario $victima es:${yellowColour} $palabra${endColour}"
			   encontrado=1
			   break
			fi
		done
	;;

	[Nn]o)
		echo -e "${blueColour}Po ya no kieres atake, adio :(${endColour}"
		exit 0
	;;

	*)

		echo -e "${redColour}ERROR! Tienes que escribir si o no${endColour}"
		exit 0
	;;

esac

if [[ $encontrado -eq 1 ]];then
	echo -e "\n${greenColour}######################${endColour}"
	echo -e "${greenColour}######################${endColour}"
	echo -e "${whiteColour}######################${endColour}"
	echo -e "${whiteColour}######################${endColour}"
	echo -e "${greenColour}######################${endColour}"
	echo -e "${greenColour}######################${endColour}\n"

	echo "¡¡¡VIVA ANDALUZIA COHONE!!!"
else
	echo "No se ha dao con la contraseña :("
fi


echo -en "${yellowColour}¿Quieres borrar el diccionario creado? si/no:${endColour} "
read sinodic

if [ $sinodic == "si" ]; then
	echo "Borrando diccionario.txt..."
	sleep 2
	rm diccionario.txt
else
	echo "El fichero del diccionario se llama diccionario.txt"
fi

### FELIZ NAVIDAD ####

