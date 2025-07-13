{}:

{
  name = "vite";
  ansiColor = "36";

  setup = ''
    export PORT="${PORT:-3000}"
    export RUBY_DEBUG_OPEN="true"
    export RUBY_DEBUG_LAZY="true"
  '';
  
  run = ''
    vite dev
  '';
}
