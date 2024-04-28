#!/bin/bash

# Die Datei, die die Repository-Informationen enthaelt
MODULES_FILE="modules"

# Durchlaufe die Datei, um alle Repository-URLs und ihre entsprechenden Commit-Variablen zu finden
while IFS= read -r line; do
    #  ^|berpr  fe, ob die Zeile eine Repository-URL ist
    if [[ "$line" == "PACKAGES_"*"_REPO="* ]]; then
        # Extrahiere den Repository-Namen und die URL
        REPO_NAME=$(echo "$line" | cut -d '=' -f 1)
        REPO_URL=$(echo "$line" | cut -d '=' -f 2-)

        # Den neuesten Commit für das Repository abrufen
        NEW_COMMIT=$(git ls-remote "$REPO_URL" | grep -oE '[0-9a-f]{40}' | head -n1)

        # Überprüfen, ob ein neuer Commit gefunden wurde
        if [ -n "$NEW_COMMIT" ]; then
            # Den Wert des Commits in der Datei aktualisieren
            COMMIT_LINE=$(grep -n "${REPO_NAME/_REPO/_COMMIT}" "$MODULES_FILE" | cut -d ':' -f 1)
            sed -i "${COMMIT_LINE}s/.*/${REPO_NAME/_REPO/_COMMIT}=$NEW_COMMIT/" "$MODULES_FILE"
            echo "Der Wert von ${REPO_NAME/_REPO/_COMMIT} wurde auf den neuesten Commit ($NEW_COMMIT) aktualisiert."
        else
            echo "Fehler: Der neueste Commit f  r $REPO_NAME konnte nicht abgerufen werden."
        fi
    fi
done < "$MODULES_FILE"
