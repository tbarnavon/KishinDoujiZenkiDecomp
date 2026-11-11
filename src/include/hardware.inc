;; hardware.inc - ports et registres materiels SMS / Game Gear
;; Ecrit a la main (non genere). Inclus par tous les modules.

;; ---- VDP
VDP_DATA        = 0xBE      ; donnee VRAM/CRAM (lecture/ecriture)
VDP_CTRL        = 0xBF      ; ecriture : commande d'adresse ou de registre
VDP_STATUS      = 0xBF      ; lecture : statut (bit 7 = VBlank, acquitte l'IRQ)
VDP_VCOUNTER    = 0x7E      ; lecture : ligne courante
VDP_HCOUNTER    = 0x7F      ; lecture : position horizontale

;; Commandes VDP (octet de poids fort de l'adresse envoyee sur VDP_CTRL)
VDP_CMD_VRAM_READ  = 0x00
VDP_CMD_VRAM_WRITE = 0x40
VDP_CMD_REGISTER   = 0x80
VDP_CMD_CRAM_WRITE = 0xC0

;; ---- PSG (SN76489)
PSG_PORT        = 0x7F
PSG_PORT_ALT    = 0x7E      ; miroir

;; ---- Entrees
IO_PORT_A       = 0xDC      ; manette 1 + haut/bas manette 2 (actif bas)
IO_PORT_B       = 0xDD      ; manette 2 + reset (actif bas)
MEM_CTRL        = 0x3E
IO_CTRL         = 0x3F

;; ---- Game Gear uniquement
GG_START        = 0x00      ; bit 7 = Start (actif bas)
GG_PORT_00      = 0x00
GG_STEREO       = 0x06      ; repartition stereo du PSG

;; ---- Mapper Sega (ecriture en RAM haute)
MAPPER_CTRL     = 0xFFFC
MAPPER_SLOT0    = 0xFFFD    ; $0000-$3FFF (le premier Ko reste fixe)
MAPPER_SLOT1    = 0xFFFE    ; $4000-$7FFF
MAPPER_SLOT2    = 0xFFFF    ; $8000-$BFFF

;; ---- Commandes VDP sur 16 bits (valeur de de pour rst 0x10 : e puis d)
VDP_VRAM_WRITE  = 0x4000    ; | adresse VRAM ($0000-$3FFF)
VDP_CRAM_WRITE  = 0xC000    ; | index de couleur
VDP_REG_0       = 0x8000    ; | valeur : registre 0 (mode, masquage colonne gauche, IRQ ligne)
VDP_REG_1       = 0x8100    ; registre 1 (affichage, IRQ trame, taille sprites)
VDP_REG_2       = 0x8200    ; table des noms
VDP_REG_3       = 0x8300
VDP_REG_4       = 0x8400
VDP_REG_5       = 0x8500    ; table des attributs de sprites
VDP_REG_6       = 0x8600    ; tuiles des sprites
VDP_REG_7       = 0x8700    ; couleur de bordure
VDP_REG_8       = 0x8800    ; defilement horizontal
VDP_REG_9       = 0x8900    ; defilement vertical
VDP_REG_10      = 0x8A00    ; compteur de lignes (IRQ de ligne)
