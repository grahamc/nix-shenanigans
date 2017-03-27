{ testfile ? ./test/attrset.nix }:
let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;

  callOrRet = x:
    if (builtins.isFunction x)
    then x {}
    else x;

  loadInput = src: callOrRet (import src);

  flatten = val:
    builtins.listToAttrs (
    if lib.isList val then (flattenListToAttrList "top" val)
    else if lib.isAttrs val then (flattenAttrsetToAttrList "top" val)
    else throw "flatten can't handle this? ${val}"
    );

  flatten' = prefix: val:
    (
      if lib.isDerivation val then [(lib.nameValuePair prefix val)]
      else if lib.isBool val then [(lib.nameValuePair prefix val)]
      else if lib.isInt val then [(lib.nameValuePair prefix val)]
      else if lib.isString val then [(lib.nameValuePair prefix val)]
      else if lib.isFunction val then (flatten' prefix (val {}))
      else if lib.isList val then (flattenListToAttrList prefix val)
      else if lib.isAttrs val then (flattenAttrsetToAttrList prefix val)
      else throw "flatten' can't handle this? ${val}"
    );

  flattenAttrsetToAttrList = prefix: attrset:
    let
      keys = builtins.attrNames attrset;
    in builtins.concatLists (
        map (key: (
          let
            ident = "${prefix}.${key}";
            curValue = (builtins.getAttr key attrset);
          in flatten' ident curValue
        )) keys
      )
    ;

  flattenListToAttrList = prefix: xs:
    builtins.concatLists
      (lib.imap
        (i: v:
          let
            ident = "${prefix}-${toString (i - 1)}";
          in
            flatten' ident v
        )
        xs);

in { flat = (flatten (loadInput testfile)); }
