
{}:

{
  name = "rails";
  ansiColor = "35";

  setup = ''
    export PORT="${PORT:-3000}"
    export RUBY_DEBUG_OPEN="true"
    export RUBY_DEBUG_LAZY="true"
  '';
  
  run = ''
    bin/rails s
  '';
}
