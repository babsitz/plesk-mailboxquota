# plesk-mailboxquota

Mit diesem Script werden alle Mailboxen durchsucht und ab 95 % Speicherplatzbelegung bekommt der Mailuser eine Warnmail geschickt. Die 95% sind standardmäßig eingestellt und lassen sich in der Zeile
SOFTQUOTA=$((95 * $HARDQUOTA / 100))
ändern.

Für den Betrieb wird bc benötigt. Bei Debian kann dies einfach per "apt-get bc" installiert werden.

Autor: Jörg Klebsattel

Lizenz: GPL