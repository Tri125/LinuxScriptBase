#!/bin/bash 

# Tristan Savaria
# 07/04/2015


#Demande l'utilisateur d'appuyer sur une touche, pause l'exécution
function pause()
{
	#ligne vide
	echo
	# s pas faire d'echo, -n retourne après avoir lu n charactère (1 ici) -p prompt -r les backslash ne peuvent pas échapper les caractères.
	read -sp "Appuyez sur une touche pour continuer..." -n 1 -r 
	#Ligne vide
	echo
}

#Demande à l'utilisateur le path d'un répertoire et affiche son contenu.
function voirRepertoire()
{
	#Variable utilisé pour faire une boucle dans la fonction.
	bon=0
	# Jusqu'à temps que la variable bon n'est pas égal à 1.
	until [ $bon -eq "1" ]; do
		#Fait une ligne vide
        echo
		#Présente un message au terminal et enregistre la réponse dans la variable n
		read -p "Répertoire à voir: " n
	 	#si c'est un répertoire
 		if [ -d "$n" ]
		then
			# Pour sortir de la boucle.
			bon=1
	 		#list le contenu de la variable n contenant le chemin d'un dossier.
	 		ls $n
        	pause
 		else
  			echo "$n n'est pas un répertoire."
  			pause
 		fi
 	done
}

#Demande à l'utilisateur le nom d'un fichier pour le modifier.
function editerFichier()
{
	#Variable utilisé pour faire une boucle dans la fonction.
	bon=0
	# Jusqu'à temps que la variable bon n'est pas égal à 1.
	until [ $bon -eq "1" ]; do
		#Fait une ligne vide
		echo
 		#Présente un message au terminal et enregistre la réponse de l'utilisateur dans la variable n.
		read -p "Fichier à editer: " n
		#Si n est un fichier (-f) et (-a) que l'utilisateur a la permission d'écriture (-w)
		# et (-a) la permission de lecture (-r)
		if [ -f "$n" -a -w "$n" -a -r "$n" ]
  		then
  			# Pour sortir de la boucle.
			bon=1
    		#Ouvre le fichier avec l'éditeur de texte nano. Si j'ouvre vim ou emac je ne sais même pas comment sortir sans tuer le process :/
    		#C'est une application ligne de commande, alors non merci pour gedit.
    		nano $n
    		pause
 		else
  			echo "Le fichier n'existe pas ou vous n'avez pas les permissions de le modifier."
  			pause
 		fi
	done
}

#Demande à l'utilisateur le nom d'un fichier et demande une confirmation pour le supprimer.
function supprimerUnFichier()
{
	#Variable utilisé pour faire une boucle dans la fonction.
	bon=0
	# Jusqu'à temps que la variable bon n'est pas égal à 1.
	until [ $bon -eq "1" ]; do
		#Fait une ligne vide
		echo
		#Présente un message au terminal et enregistre la réponse de l'utilisateur dans la variable n.
		read -p "Fichier à supprimer: " n
		#Si n est un fichier (-f) et (-a) que l'utilisateur à la permission d'écriture (-w) dessus.
		if [ -f "$n" -a -w "$n" ]
		then
			# Pour sortir de la boucle.
			bon=1
			# http://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script
			# http://mywiki.wooledge.org/BashFAQ/031
	   		# -n retourne après avoir lu n charactère (1 ici) -p prompt -r les backslash ne peuvent pas échapper les caractères.
	   		read -p "Êtes-vous certain de vouloir supprimer $n (O/N) ? " -n 1 -r
	   		echo
	   		# [[ sont utilisé pour évaluer des expressions, ne fonctionnent pas sous tout les shell, mais
	   		# rajoute des nouvelles fonctionalitées sur [ que l'on utilise habituellement pour les évaluations.
	   		# En utilisant les nouveaux tests, l'opérateur =~ peut être utilisé pour utilisé une regex.
	   		# Le test est vrai s'il y a au moins match avec la regex.
	   		# ^[Oo]$ La chaine doit commencer et ce terminer par un caractère contenu dans l'ensemble [Oo].
	   		# Donc seulement si l'utilisateur écrit "O" ou "o".
	   		# REPLY est la variable interne par défaut lorsqu'aucune variable est donnné à read.
	   		if [[ $REPLY =~ ^[Oo]$ ]]
	   		then
	    		#Supprime le fichier n.
	    		rm $n
	    		echo "Fichier $n supprimé"
	    		pause
	   		else
	    		#Aucun match avec la regex, annule l'opération.
	    		echo "Opération annulé"
	    		pause
	   		fi
	 	else
	  		echo "Le fichier n'existe pas ou vous n'avez pas les permissions nécessaires"
	  		pause
	 	fi
	done

}

#Permet la création d'un nouveau compte et vérifie si un compte avec le même nom existe déjà
function nouveauCompte()
{
	#Effective user ID, le numéro d'identification de l'identité que l'utilisateur courant assume.
	# 0 est le UID de root, le premier compte créer dans chaque system Linux.
	# Si EUID n'est pas égal à 0, donc si le script n'est pas exécuté en tant que root.
	if [ "$EUID" -ne 0 ]
		#On termine la fonction, car on ne peut pas créer de compte sans être root.
		then echo "Veuillez exécuter en tant que root"
	  	pause
	  	# 1 pour erreur.
	  	return 1
	fi
	#Variable utilisé pour faire une boucle dans la fonction lorsque le nom de compte existe déjà pour redommander de nouveau.
	bon=0
	# Jusqu'à temps que la variable bon n'est pas égal à 1.
	until [ $bon -eq "1" ]; do
		#Fait une ligne vide
	    echo
		#Présente un message au terminal et enregistre la réponse de l'utilisateur dans la variable n.
	    read -p "Nom de compte: " n
	 	# -z La chaîne est vide. La chaine est une expression, donc on encadre avec $()
	 	# cat fait la concaténation du fichier /etc/passwd que l'on pipe dans cut. -d: déliminateur : , -f1 champs 1.
	 	# Prend le contenu du fichier et on garde seulement le premier champs, le nom des comptes du système.
	 	# Pipe le résultat dans grep pour faire une recherche avec la regex. ^ débute, $ fini.
	 	# On veut un match parfais, c'est pour sa que la regex commence par $n et ce termine immédiatement, ne permet pas le match avec des sous-chaines.
	 	if [ -z "$(cat /etc/passwd | cut -d: -f1 | grep "^$n$")" ]
	  	then
			# Si la chaîne est vide, aucun match, donc le compte n'est pas déjà dans le système.
			# Pour sortir de la boucle.
			bon=1
			# Créer le compte, -m pour créer le home directory
			useradd -m $n
			# Change le mot de passe pour le compte
			#passwd $n
			echo "Compte $n créé."
	        pause
	 	else
			# Un match, donc le compte existe déjà.
	  		echo "Le compte $n existe déjà, veuillez entrer un autre nom."
	  		pause
	 	fi
	done
}




while true
do
	# Variable interne de prompt tertiaire, affiché dans les boucles select.
	PS3="Entrez le numéro de votre choix -> " 
	echo "Quelle opération voulez-vous exécuter ?" 
	# Choix de menu dans un ensemble.
	select operation in "Voir le contenue d'un répertoire" "Editer un fichier" "Supprimer un fichier" "Créer un compte utilisateur" "Sortir du menu" 
	do 
		# Évalue le choix avec un switch case, lance une fonction pour chaque.
		case $REPLY in
			1) voirRepertoire ; break ;;
			2) editerFichier ; break ;;
			3) supprimerUnFichier ; break ;;
			4) nouveauCompte ; break ;;
			5) echo "Au revoir !" ; exit ;;
			# Défault
			*) echo "Erreur : entrez un des chiffres proposés." ; break ;;
		esac 
	 	echo 
	done
done
