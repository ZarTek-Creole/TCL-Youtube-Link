<span class="badge-opencollective"><a href="https://github.com/ZarTek-Creole/DONATE" title="Donate to this project"><img src="https://img.shields.io/badge/open%20collective-donate-yellow.svg" alt="Open Collective donate button" /></a></span>
[![CC BY 4.0][cc-by-shield]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg

* Ce script récupère des informations sur les titres Youtube à l'aide de l'**API Youtube V3**.
* Il permet de rechercher des titres avec des mots clefs
* Il écoute les liens youtube sur les salons et affiche les informations des titres
* Les annonces sont totalement personnalisables : Couleurs, informations : Durée, etc

![image](https://user-images.githubusercontent.com/11725850/119846268-4699e100-bf0a-11eb-80f1-7cf5c7fbb5bc.png)

# Auteur
ZarTek-Creole @ github.com/ZarTek-Creole

# Pre-requis
* eggdrop min v1.6.20 
* package tcl min v8.5
* package tls min v1.7.11
* package http min v2.8.9
* package json min v1.3
* package clock::iso8601 min v0.1

# Website
Site internet officiel du script TCL-Youtube
* github.com/ZarTek-Creole/TCL-Youtube-Link

# Support
Si vous avez des remarques, des suggestions, des idées, des bogues vous pouvez me les faire parvenir via le formulaire issue:
* github.com/ZarTek-Creole/TCL-Youtube-Link/issues

# Docs
## Téléchargement
Utilisez la methode git, elle vous permet par la suite de mettre à jour le script facilement
```
git clone https://github.com/ZarTek-Creole/TCL-Youtube-Link /home/<eggdrop>/scripts/
```
## Installation & Configuration
Verifiez que le répertoire se trouve bien dans le répertoire `scripts/` de votre eggdrop.

Editez le fichier Youtube-link.tcl, en renseignant les variables au début par rapport à vos envies/besoins.

Mettez bien une clef API que vous pouvez obtenir gratuitement sur https://console.cloud.google.com/apis/api/youtube.googleapis.com/overview

Ajoutez dans votre fichier eggdrop.conf la ligne :

```
source scripts/TCL-Youtube-Link/Youtube-Link.tcl
```
# Configuration des salons
## Par Flags
### Activation sur un salon spécifique
```
.chanset #channel +youtube
```
### Activation sur tous les salons
```
.chanset * +youtube
```
## Par liste de salons

### Activation sur certains salons
```
set Channels(Allow)     "#channel1  #channel2"
```

### Activation sur tous les salons
```
set Channels(Allow)		"*"
```

Rehashez ou redemmarez votre eggdrop.

# Donation
Si le script ou le travail accompli vous plaît, vous pouvez faire un don pour m'encourager :
* https://ko-fi.com/zartek
* github.com/ZarTek-Creole/DONATE

# Thank's
Merci aux différentes personnes qui ont permi la réalisation du script:

Nom | participation | url
---------|----------|---------
m00nie | base code | www.m00nie.com
Imhotep | ask and details	| www.eggdrop.fr
CrazyCat | community french and help of eggdrop | https://www.eggdrop.fr
MenzAgitat | tips/toolbox | https://www.boulets.oqp.me/

# Contributeurs
Toute contribution est la bienvenue

# Documentation du code
https://zartek-creole.github.io/TCL-Youtube-Link/
