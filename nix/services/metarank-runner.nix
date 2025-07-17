{}:

{
  name = "metarank";
  ansiColor = "36";

  # Is there an error here? ^.^
  # setup = ''
  #   export METARANK_PORT="${METARANK_PORT:-8080}"
  # '';

  run = ''
    metarank serve --config ./metarank/config.yml
  '';
}
