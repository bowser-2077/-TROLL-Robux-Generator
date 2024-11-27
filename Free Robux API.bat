@echo off
:: Initialisation de la variable mineRobux ? 0
set /a mineRobux=0

:: D?finir un fichier temporaire pour stocker les Robux extraits et les param?tres de l'utilisateur
set tempFile=%temp%\robux_balance.txt
set logFile=%temp%\robux_log.txt

:: Effacer le fichier pr?c?dent s'il existe
if exist "%tempFile%" del "%tempFile%"
if exist "%logFile%" del "%logFile%"

:: Sauvegarder la valeur initiale des Robux extraits (0 au d?but)
echo %mineRobux% > "%tempFile%"

:: Demande ? l'utilisateur d'entrer une commande
:menu
set /p userInput=Entrez une commande : 

:: V?rifie si l'entr?e correspond ? "start --mine --normal"
if "%userInput%"=="start --mine --normal" (
    goto mineLoopNormal
)

:: V?rifie si l'entr?e correspond ? "start --mine --boost"
if "%userInput%"=="start --mine --boost" (
    goto mineLoopBoost
)

:: V?rifie si l'entr?e correspond ? "withdraw"
if /i "%userInput%"=="withdraw" (
    goto withdrawMenu
)

:: V?rifie si l'entr?e correspond ? "stats"
if /i "%userInput%"=="stats" (
    goto showStats
)

:: V?rifie si l'entr?e correspond ? "help"
if /i "%userInput%"=="help" (
    goto showHelp
)

:: V?rifie si l'entr?e correspond ? "balance" ou "bal"
if /i "%userInput%"=="balance" (
    goto showBalance
)

if /i "%userInput%"=="bal" (
    goto showBalance
)

:: V?rifie si l'entr?e correspond ? "stop" pour arr?ter le minage
if /i "%userInput%"=="stop" (
    echo Minage arr?t?.
    goto menu
)

:: Affiche un message d'erreur si la commande est inconnue
echo Commande inconnue : %userInput%
goto menu

:mineLoopNormal
:: Boucle d'extraction de Robux avec timeout
echo D?marrage de l'extraction normale...
:mineNormal
:: V?rifier si l'utilisateur a entr? la commande "stop"
set /p stopCheck=Entrez une commande (ou appuyez sur Entr?e pour continuer minage) : 
if /i "%stopCheck%"=="stop" goto stopMining

:: G?n?re un nombre al?atoire entre 5 et 10
set /a randNum=%random% %% 6 + 5

:: Incr?mente le nombre de Robux extraits
set /a mineRobux+=%randNum%

:: Sauvegarde la valeur des Robux dans le fichier temporaire
echo %mineRobux% > "%tempFile%"

:: Affiche le nombre de Robux extraits
echo %mineRobux% Robux mined.

:: Attendre 1 seconde pour que l'augmentation soit visible
timeout /t 1 >nul

:: Continue la boucle d'extraction
goto mineNormal

:mineLoopBoost
:: Boucle d'extraction de Robux sans timeout (mode boost)
echo D?marrage de l'extraction boost?e...
:mineBoost
:: V?rifier si l'utilisateur a entr? la commande "stop"
set /p stopCheck=Entrez une commande (ou appuyez sur Entr?e pour continuer minage) : 
if /i "%stopCheck%"=="stop" goto stopMining

:: G?n?re un nombre al?atoire entre 5 et 10
set /a randNum=%random% %% 6 + 5

:: Incr?mente le nombre de Robux extraits
set /a mineRobux+=%randNum%

:: Sauvegarde la valeur des Robux dans le fichier temporaire
echo %mineRobux% > "%tempFile%"

:: Affiche le nombre de Robux extraits
echo %mineRobux% Robux mined.

:: Pas de timeout, continue imm?diatement
goto mineBoost

:stopMining
:: Interrompt le minage et retourne au menu
echo Minage arr?t?.
goto menu

:isNumber
:: V?rifie si l'argument est un nombre valide
setlocal enabledelayedexpansion
set num=%1
set valid=true
for /l %%i in (0,1,9) do (
    set digit=!num:~%%i,1!
    if not "!digit!"=="0" if not "!digit!"=="1" if not "!digit!"=="2" if not "!digit!"=="3" if not "!digit!"=="4" if not "!digit!"=="5" if not "!digit!"=="6" if not "!digit!"=="7" if not "!digit!"=="8" if not "!digit!"=="9" (
        set valid=false
    )
)
if "!valid!"=="false" exit /b 1
exit /b 0

:withdrawMenu
:: Menu interactif pour le retrait de Robux
echo Menu de retrait de Robux :
echo.

:: Afficher le solde actuel de Robux
set /p currentRobux=<"%tempFile%"
echo Votre solde actuel de Robux est : %currentRobux%

:: Demander ? l'utilisateur combien de Robux il souhaite retirer
:askAmount
set /p withdrawAmount=Combien de Robux voulez-vous retirer ? 

:: V?rifier si l'entr?e est un nombre valide
call :isNumber %withdrawAmount%
if errorlevel 1 (
    echo Vous devez entrer un nombre valide. Essayez encore.
    goto askAmount
)

:: V?rifier si le montant est l'un des montants autoris?s (100, 500, 1000, 10000)
if not "%withdrawAmount%"=="100" if not "%withdrawAmount%"=="500" if not "%withdrawAmount%"=="1000" if not "%withdrawAmount%"=="10000" (
    echo Vous pouvez uniquement retirer 100, 500, 1000 ou 10000 Robux.
    goto askAmount
)

:: V?rifier si le montant demand? est disponible
if %withdrawAmount% leq %currentRobux% (
    :: Demander le nom du compte pour effectuer le retrait
    set /p accountName=Entrez le nom du compte pour lequel vous souhaitez effectuer le retrait : 

    :: Demander confirmation avant d'effectuer le retrait
    set /p confirmation=Confirmez-vous le retrait de %withdrawAmount% Robux pour le compte "%accountName%" (oui/non) ? 

    if /i "%confirmation%"=="oui" (
        echo Retrait de %withdrawAmount% Robux pour le compte %accountName% effectu? avec succ?s.
        set /a currentRobux-=withdrawAmount
        echo %currentRobux% > "%tempFile%"
        echo [%date% %time%] Retrait de %withdrawAmount% Robux pour %accountName% >> %logFile%
    ) else (
        echo Retrait annul?.
    )
) else (
    echo Vous n'avez pas assez de Robux pour effectuer ce retrait.
)

goto menu

:showBalance
:: Affiche le nombre de Robux min? actuellement
set /p currentRobux=<"%tempFile%"
echo Vous avez actuellement %currentRobux% Robux min?s.
goto menu

:showStats
:: Affiche les statistiques de minage
set /p currentRobux=<"%tempFile%"
echo Statistiques :
echo Robux extraits : %currentRobux%
echo.
goto menu

:showHelp
:: Affiche la liste des commandes disponibles
echo Liste des commandes disponibles :
echo.
echo start --mine --normal    : Lancer l'extraction de Robux avec une pause de 1 seconde entre chaque incr?ment.
echo start --mine --boost     : Lancer l'extraction de Robux sans pause entre les incr?ments (mode boost).
echo withdraw                 : Ouvrir le menu interactif pour effectuer un retrait de Robux.
echo stats                    : Afficher les statistiques de minage (Robux extraits, temps ?coul?).
echo balance / bal            : Afficher le nombre de Robux min?s actuellement.
echo stop                     : Arr?ter le processus de minage en cours.
echo help                     : Afficher la liste des commandes disponibles.
echo.
goto menu
