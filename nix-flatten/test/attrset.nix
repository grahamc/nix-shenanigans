{}:
let
  pkgs = import <nixpkgs> {};
  example = name: (if false then name else pkgs.writeText name name);
in {
  foo = example "foo";

  too = {}: example "foo";

  bar = {
    raz = example "bar.raz";
    baz = {
      faz = example "bar.baz.faz";
      chaz = example "bar.baz.chaz";
    };
  };

  zip = [
    {
      zop = example "zip.0.zop";
    }
    {
      top = example "zip.1.top";
    }
    (example "zip.2")
  ];

  bop = [
    (example "bop.0")
    (example "bop.1")
    (example "bop.2")
  ];
}
