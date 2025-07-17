{}:

{
  name = "metarank";
  ansiColor = "36";

  setup = ''
    export METARANK_PORT="${METARANK_PORT:-8080}"
  '';

  run = ''
    metarank serve --config metarank/config.yml --data metarank/data
  '';
}
