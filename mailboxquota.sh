#! /bin/bash
# Mail quota reaching it's limit e-mail notification
# script for Plesk
# updatet for Debian 8

MAILROOT=/var/qmail/mailnames

cd $MAILROOT > /dev/null
for DIR in *.*;do
        cd $MAILROOT/$DIR
        for MAILBOX in * ;do
                if [ -d $MAILBOX ]
                        then

                        # look for specific mailbox quota file and set mailbox softquota
                        QUOTAFILE=$MAILROOT/$DIR/$MAILBOX/Maildir/maildirsize
			
			# Fetching mailbox quota size in bytes
			HARDQUOTA=$((`head -1 $QUOTAFILE 2>/dev/null | cut -d S -f1`)) >/dev/null 2>&1 #für Fehler und normale Ausgabe
			if [ "$HARDQUOTA" -eq 0 ]; then 
				continue
			fi
		
			# Fetching space used by mailbox in bytes
			MBOXSPACE=$((`tail -n +2 $QUOTAFILE | cut -c1-12 | perl -lne '$x+=$_; END{print $x;}'`))
 
			# Calculate the quota limit required for mail warning (85% for default)
			SOFTQUOTA=$((95 * $HARDQUOTA / 100))

			# Calculate mailbox usage percentage (with two decimals)
			MBOXPERCENT=$(echo "scale=2; $MBOXSPACE*100/$HARDQUOTA" | bc)

			# Check if the mailbox is full enough for warning, and if, send the warning mail
            if [ $HARDQUOTA -gt 0 -a $MBOXSPACE -gt $SOFTQUOTA ]; then
			
				# Let's generate the values in megabytes (with two decimals)
				HARDQUOTA=$(echo "scale=2; $HARDQUOTA/1048576" | bc)
				if [ "$(echo $HARDQUOTA | cut -c1)" = "." ] ; then HARDQUOTA="0"$HARDQUOTA
				fi
				MBOXSPACE=$(echo "scale=2; $MBOXSPACE/1048576" | bc)
				if [ "$(echo $MBOXSPACE | cut -c1)" = "." ] ; then MBOXSPACE="0"$MBOXSPACE
				fi
			
/usr/sbin/sendmail -t << EOF
To: $MAILBOX@$DIR
From: noreply@$DIR
Subject: [WARNUNG] E-Mail Speicherwarnung!
X-Priority: 1 (Highest)
X-MSMail-Priority: High
Lieber Mailboxbenutzer,

Ihre E-Mailadresse '$MAILBOX@$DIR' erreicht demnaechst den maximalen Speicherplatz. Momentan werden $MBOXSPACE MB ($MBOXPERCENT%) des maximalen Speicherplatzes von $HARDQUOTA MB benutzt.

Wir moechten Ihnen raten, dass Sie ein paar aeltere Mails loeschen, um wieder Speicherplatz freizugeben. Sollten Sie Ihren Speicherplatz ueberschritten haben, werden Sie nicht mehr in der Lage sein Mails zu empfangen. E-Mails an Ihre Adresse werden dann mit dem Hinweis 'mail quota exceeded' an den Absender zurueckgesandt.

Die andere Option waere, ihren Mailclient auf das POP3-Protokoll umzustellen. Bei jedem Mailabruf werden die Mails dann auf dem Server geloescht und auf Ihren Mailclient heruntergeladen. Sie koennen dann allerdings nicht mehr von jedem Client aus auf diese Mails zugreifen.


Mit freundlichen Gruessen
postmaster(a)'$DIR'

Dies ist eine automatisch generierte E-Mail
EOF

			fi


				fi
        done;

done;
