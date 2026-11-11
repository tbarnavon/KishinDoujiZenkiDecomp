# Décisions

Choix faits avec l'utilisateur, dans l'ordre chronologique (2026-11-11).

| Sujet | Décision | Raison |
|---|---|---|
| Plateforme cible | **Master System** | demande de l'utilisateur |
| Version de base | **SMS EN** (hack GG2SMS v0.3) ; la **GG JP** reste productible (`VERSION=gg_jp`) | même code aux mêmes adresses : surcoût faible |
| Taille de ROM | 1 Mo identique au hack, puis option `TRIM=1` | contrôle octet pour octet d'abord |
| Build | **script Python** `tools/build.py` (pas de make) | make absent, choix de l'utilisateur |
| Compilateur | **SDCC 4.1.0 local** (`tools/sdcc-4.1.0`), pas le SDCC 4.6 global | devkitSMS 1.2 exige SDCC ≤ 4.1.11 (ancienne convention d'appel) ; 4.1.11 introuvable, 4.1.0 = version recommandée par devkitSMS |
| devkitSMS | 1.2, extrait dans `tools/devkitSMS/` | dernière version selon l'utilisateur |
| Désassembleur | traceur Python maison + z80dasm (WSL) en second avis | sortie directement compatible sdasz80 |
| Émulateur | **Emulicious** (Java embarqué) dans `tools/emulicious/` | fourni par l'utilisateur |
| Découpage | modules par responsabilité : `core/ video/ audio/ input/ game/ screens/ data/ version/` | validé par l'utilisateur |
| Routines inconnues | d'abord `src/unsorted/` provisoire, puis classées (fait : `unsorted/` supprimé) | rebuild rapide, puis migration |
| Langue | **labels en anglais, commentaires en français** | validé par l'utilisateur |
| Documentation | dossier `docs/` du projet (pas de mémoire externe) | demande de l'utilisateur |
| Banques 2 et 23 | désassemblage étendu (passage spéculatif en slot 2) | elles contiennent du code (62 appels vers le moteur, tous retrouvés) |
| Étape 4 : priorité | **textes + scripts de scènes** d'abord (banques 5, 32-33) | les scripts chargent les graphismes : leur décodage typera les autres banques |
| Assets éditables | SMS EN uniquement ; GG JP exportée en lecture seule | cible = SMS ; les données JP sont désordonnées |
| Graphismes modifiés trop grands | déplacés automatiquement en banques libres 34-63, scripts corrigés à la compilation | évite de limiter l'édition à la taille d'origine |
| Fichiers édités | `extract` refuse d'écraser sans `FORCE=1` ; le build supprime l'ancienne ROM avant de construire | ne jamais perdre une modification ni vérifier une ROM périmée |
| Autonomie | à partir de l'étape 5, travail autonome ; retour vers l'utilisateur seulement en cas de problème ou à la fin | demande de l'utilisateur (2026-11-11) |
| Étape 5 : ordre | (1) adresses en dur → labels/constantes (ROM identique), (2) RAM nommée par module, (3) gel de `src/` | chaque étape reste vérifiable octet pour octet jusqu'au C |
| Réécriture en C | **tentée puis abandonnée et retirée** (2026-11-11) : un module (`input/joypad`) avait été porté et validé, puis l'utilisateur a choisi de s'en passer ; le projet est 100 % assembleur | le jeu est modifiable via `assets/` et `src/` |
