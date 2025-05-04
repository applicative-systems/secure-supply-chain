# super dirty hack to disable `shellcheck` image-wide.
# Shellcheck is written in Haskell and requires haskell runtime.
# That's of course not generally a problem but for the source closure this
# means including the haskell compiler source.

{
  nixpkgs.overlays = [
    (final: prev: {
      shellcheck-minimal = (prev.runCommand "shellcheck" {} ''
        mkdir -p $out/bin
        cat > $out/bin/shellcheck <<EOF
        #!${final.bash}/bin/bash
        true
        EOF
        chmod +x $out/bin/shellcheck
      '') // {
        compiler = final.hello;
        meta.mainProgram = "shellcheck";
      };
    })
  ];
}
