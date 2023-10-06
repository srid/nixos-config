{ writeShellApplication, sqlite, ... }:

writeShellApplication {
  name = "mood";
  runtimeInputs = [ sqlite ];
  text = ''
    echo "Inserting mood: $1"
    sqlite3 ~/.dioxus-desktop-template.db "INSERT INTO mood VALUES (CURRENT_TIMESTAMP, $1);"
    echo "Displaying recent entries:"
    sqlite3 ~/.dioxus-desktop-template.db "SELECT * FROM mood ORDER BY datetime DESC LIMIT 10;"
  '';
}
